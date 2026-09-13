local transport = require('ai.transport')
local context = require('ai.context')
local util = require('ai.util')

local M = {}

local state = { history_buf = nil, chat_id = nil, busy = false, queue = {} }

local YOU_MARKER = '## you'
local ASSISTANT_MARKER = '## model'
local MAX_CONTEXT_REQUESTS = 15

local function history_path()
    return util.project_root() .. '/CHAT-HISTORY.md'
end

local function turn_finished()
    state.busy = false
    local next_turn = table.remove(state.queue, 1)
    if next_turn then
        state.busy = true
        next_turn()
    end
end

local function run_or_queue(fn)
    if state.busy then
        table.insert(state.queue, fn)
        vim.notify(string.format('AiChat: queued (%d waiting)', #state.queue), vim.log.levels.INFO)
        return
    end
    state.busy = true
    fn()
end

local function write_fresh(path)
    vim.fn.writefile({ YOU_MARKER, '' }, path)
end

local function ensure_file()
    local path = history_path()
    if vim.fn.filereadable(path) == 0 then
        write_fresh(path)
    end
    return path
end

local function with_modifiable(buf, fn)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    fn()
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

-- ensure_window opens (or reuses) the readonly history split. It never steals
-- focus if the split is already open elsewhere and visible; it only creates
-- one (leaving focus on it) the first time, or when it's been hidden.
local function ensure_window()
    local path = ensure_file()

    if state.history_buf and vim.api.nvim_buf_is_valid(state.history_buf) then
        if not vim.fn.win_findbuf(state.history_buf)[1] then
            vim.cmd('botright vertical sbuffer ' .. state.history_buf)
        end
        return state.history_buf
    end

    vim.cmd('botright vertical split ' .. vim.fn.fnameescape(path))
    state.history_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(state.history_buf, 'modifiable', false)

    return state.history_buf
end

local function current_context()
    local bufnr = vim.api.nvim_get_current_buf()
    local ctx = { cwd = util.project_root() }
    local name = vim.api.nvim_buf_get_name(bufnr)

    if name == '' then
        return ctx
    end

    ctx.file = util.to_relative(name)
    ctx.content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')

    return ctx
end

local function append_lines(buf, lines)
    with_modifiable(buf, function()
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
    end)
end

-- write_history saves the (nomodifiable) history buffer. Wrapped in
-- with_modifiable because BufWritePre autocmds (e.g. trailing-whitespace
-- trim for *.md) can try to edit the buffer as part of writing it, which
-- otherwise fails with E21 since modifiable is off.
local function write_history(buf)
    with_modifiable(buf, function()
        vim.api.nvim_buf_call(buf, function()
            vim.cmd('silent write')
        end)
    end)
end

local function set_last_line(buf, text)
    with_modifiable(buf, function()
        local last = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_buf_set_lines(buf, last - 1, last, false, { text })
    end)
end

local function stream_delta(buf, streamer, text)
    local combined = streamer.pending .. text
    local parts = vim.split(combined, '\n', { plain = true })
    streamer.pending = table.remove(parts)

    if #parts > 0 then
        set_last_line(buf, parts[1])
        if #parts > 1 then
            append_lines(buf, vim.list_slice(parts, 2))
        end
        append_lines(buf, { '' })
    end

    if streamer.pending ~= '' then
        set_last_line(buf, streamer.pending)
    end
end

local function apply_edits(edits)
    if #edits == 0 then
        return
    end

    local files = {}
    for _, e in ipairs(edits) do
        files[e.file] = true
    end
    local file_list = {}
    for f in pairs(files) do
        table.insert(file_list, f)
    end

    local choice = vim.fn.confirm(
        string.format('Apply %d edit(s) to %s?', #edits, table.concat(file_list, ', ')),
        '&Yes\n&No'
    )
    if choice ~= 1 then
        return
    end

    local by_file = {}
    for _, e in ipairs(edits) do
        by_file[e.file] = by_file[e.file] or {}
        table.insert(by_file[e.file], e)
    end

    for file, file_edits in pairs(by_file) do
        table.sort(file_edits, function(a, b)
            return a.start_line > b.start_line
        end)

        local abs = util.to_absolute(file)

        if vim.fn.filereadable(abs) == 0 then
            local dir = vim.fn.fnamemodify(abs, ':h')
            if dir ~= '' and vim.fn.isdirectory(dir) == 0 then
                vim.fn.mkdir(dir, 'p')
            end
            vim.fn.writefile({}, abs)
        end

        local buf = vim.fn.bufadd(abs)
        vim.fn.bufload(buf)

        for _, e in ipairs(file_edits) do
            local new_lines = vim.split((e.text:gsub('\n$', '')), '\n', { plain = true })
            vim.api.nvim_buf_set_lines(buf, e.start_line - 1, e.end_line, false, new_lines)
        end

        vim.api.nvim_buf_call(buf, function()
            vim.cmd('silent write')
        end)
    end
end

local function apply_deletes(files)
    if #files == 0 then
        return
    end

    local choice = vim.fn.confirm(
        string.format('Delete %d file(s)?\n%s', #files, table.concat(files, '\n')),
        '&Yes\n&No'
    )
    if choice ~= 1 then
        return
    end

    for _, file in ipairs(files) do
        local abs = util.to_absolute(file)
        vim.fn.delete(abs)

        local buf = vim.fn.bufnr(abs)
        if buf ~= -1 then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
end

local function handle_stream_event(buf, streamer, ctx_state, evt)
    if evt.type == 'text_delta' then
        stream_delta(buf, streamer, evt.text)
    elseif evt.type == 'edit' then
        table.insert(ctx_state.pending_edits, evt)
    elseif evt.type == 'delete_file' then
        table.insert(ctx_state.pending_deletes, evt.file)
    elseif evt.type == 'command_suggestion' then
        local lines = { '', '## suggested command', evt.command }
        if evt.reason and evt.reason ~= '' then
            table.insert(lines, '# ' .. evt.reason)
        end
        append_lines(buf, lines)
    elseif evt.type == 'error' then
        append_lines(buf, { '', '## error', evt.message })
    elseif evt.type == 'context_request' then
        ctx_state.awaiting = evt
    end
end

local function finalize_turn(buf, ctx_state)
    apply_edits(ctx_state.pending_edits)
    apply_deletes(ctx_state.pending_deletes)
    append_lines(buf, { '', YOU_MARKER, '' })
    write_history(buf)
    turn_finished()
end

local function summarize_fetched(ctx_state)
    local lines = {
        '', '## error',
        string.format('Paused after %d context fetches. Previously fetched:', MAX_CONTEXT_REQUESTS),
    }
    for _, f in ipairs(ctx_state.fetched) do
        table.insert(lines, string.format('- %s: %s', f.kind, f.path or f.query or '?'))
    end
    return lines
end

local stream_turn

local function handle_context_request(buf, streamer, ctx_state)
    local req = ctx_state.awaiting
    ctx_state.awaiting = nil
    ctx_state.count = ctx_state.count + 1

    if ctx_state.count > MAX_CONTEXT_REQUESTS then
        append_lines(buf, summarize_fetched(ctx_state))
        append_lines(buf, { '', YOU_MARKER, '' })
        write_history(buf)
        turn_finished()
        return
    end

    append_lines(buf, { string.format('[fetching %s: %s]', req.kind, req.path or req.query or '?') })

    context.resolve(req, function(content, err, meta)
        table.insert(ctx_state.fetched, meta or { kind = req.kind, path = req.path, query = req.query })

        stream_turn('/v1/chats/context', {
            chat_id = state.chat_id,
            id = req.id,
            content = content or ('error: ' .. tostring(err)),
        }, buf, streamer, ctx_state)
    end)
end

stream_turn = function(endpoint, body, buf, streamer, ctx_state)
    transport.post_stream(endpoint, body, function(evt)
        handle_stream_event(buf, streamer, ctx_state, evt)
    end, function(_)
        if ctx_state.awaiting then
            handle_context_request(buf, streamer, ctx_state)
        else
            finalize_turn(buf, ctx_state)
        end
    end)
end

local function send_message(buf, chat_id, req_type, message, req_context)
    append_lines(buf, { '', ASSISTANT_MARKER, '' })

    local streamer = { pending = '' }
    local ctx_state = { count = 0, pending_edits = {}, pending_deletes = {}, fetched = {} }

    stream_turn('/gen', {
        type = req_type,
        chat_id = chat_id,
        message = message,
        context = req_context,
    }, buf, streamer, ctx_state)
end

local function ensure_chat_id(buf, cb, on_error)
    if state.chat_id then
        cb(state.chat_id)
        return
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    transport.post('/v1/chats/new', { resume_content = table.concat(lines, '\n') }, function(resp, err)
        if err or not resp or not resp.chat_id then
            vim.notify('AiChat: failed to start chat session: ' .. (err or 'no chat_id'), vim.log.levels.ERROR)
            if on_error then
                on_error()
            end
            return
        end

        state.chat_id = resp.chat_id
        cb(state.chat_id)
    end)
end

-- send_text runs one chat turn for `message`. It ensures the history split
-- exists (opening it if needed) but never moves focus there — the caller's
-- window/buffer is left as-is.
local function send_text(message, req_context)
    local buf = ensure_window()
    local message_lines = vim.split(message, '\n', { plain = true })

    run_or_queue(function()
        local lines = { '', YOU_MARKER }
        vim.list_extend(lines, message_lines)
        table.insert(lines, '')
        append_lines(buf, lines)
        ensure_chat_id(buf, function(chat_id)
            send_message(buf, chat_id, 'chat', message, req_context)
        end, turn_finished)
    end)
end

-- open_compose pops up a small floating scratch buffer over wherever the
-- user currently is (no window switch needed to invoke it, and it never
-- takes over a permanent split) so they can write/paste a multi-line
-- message. <C-s> (works from insert mode, no need to leave it) submits;
-- <Esc>/q in normal mode cancels. The float always closes back to the
-- window the user invoked it from.
local function open_compose()
    local return_win = vim.api.nvim_get_current_win()
    local ctx = current_context()

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')

    local width = math.min(90, math.floor(vim.o.columns * 0.6))
    local height = 8
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = 'minimal',
        border = 'rounded',
        title = ' Ask AI  (<C-s> send, <Esc><Esc>/q cancel) ',
        title_pos = 'center',
    })

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_win_is_valid(return_win) then
            vim.api.nvim_set_current_win(return_win)
        end
    end

    local function submit()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local message = vim.trim(table.concat(lines, '\n'))
        -- <C-s> is bound in insert mode; leave it explicitly so the user
        -- doesn't land back in their original buffer still in insert mode
        -- once the float closes.
        vim.cmd('stopinsert')
        close()
        if message == '' then
            return
        end
        send_text(message, ctx)
    end

    vim.keymap.set({ 'n', 'i' }, '<C-s>', submit, { buffer = buf })
    vim.keymap.set('n', '<Esc>', close, { buffer = buf })
    vim.keymap.set('n', 'q', close, { buffer = buf })

    vim.cmd('startinsert')
end

M.send = open_compose

M.ask = function(instruction, ctx)
    local buf = ensure_window()

    run_or_queue(function()
        append_lines(buf, { '', YOU_MARKER, instruction, '' })
        ensure_chat_id(buf, function(chat_id)
            send_message(buf, chat_id, 'edit', instruction, ctx)
        end, turn_finished)
    end)
end

M.reset = function()
    local chat_id = state.chat_id
    local path = history_path()

    local finish = function()
        write_fresh(path)
        state.chat_id = nil

        if state.history_buf and vim.api.nvim_buf_is_valid(state.history_buf) then
            with_modifiable(state.history_buf, function()
                vim.api.nvim_buf_call(state.history_buf, function()
                    vim.cmd('edit!')
                end)
            end)
        end
    end

    if not chat_id then
        finish()
        return
    end

    transport.post('/v1/chats/reset', { chat_id = chat_id }, function(_, err)
        if err then
            vim.notify('AiChatReset: server reset failed: ' .. err, vim.log.levels.WARN)
        end
        finish()
    end)
end

M.refresh = function()
    local buf = ensure_window()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(lines, '\n')

    if not state.chat_id then
        transport.post('/v1/chats/new', { resume_content = content }, function(resp, err)
            if err or not resp or not resp.chat_id then
                vim.notify('AiChatRefresh: failed to start chat session: ' .. (err or 'no chat_id'), vim.log.levels.ERROR)
                return
            end
            state.chat_id = resp.chat_id
        end)
        return
    end

    transport.post('/v1/chats/refresh', { chat_id = state.chat_id, content = content }, function(_, err)
        if err then
            vim.notify('AiChatRefresh failed: ' .. err, vim.log.levels.ERROR)
        end
    end)
end

M.open = ensure_window

M.toggle = function()
    if state.history_buf and vim.api.nvim_buf_is_valid(state.history_buf) then
        local win = vim.fn.win_findbuf(state.history_buf)[1]
        if win then
            pcall(vim.api.nvim_win_close, win, false)
            return
        end
    end
    ensure_window()
end

vim.api.nvim_create_user_command('AiChat', M.open, {})
vim.api.nvim_create_user_command('AiChatReset', M.reset, {})
vim.api.nvim_create_user_command('AiChatRefresh', M.refresh, {})
vim.api.nvim_create_user_command('AiChatToggle', M.toggle, {})

vim.keymap.set('n', '<leader>as', M.send, { desc = 'Compose AI chat message' })
vim.keymap.set('n', '<leader>ar', M.reset, { desc = 'Reset chat history' })
vim.keymap.set('n', '<leader>af', M.refresh, { desc = 'Refresh server chat state' })
vim.keymap.set('n', '<leader>at', M.toggle, { desc = 'Toggle AI chat window' })

return M
