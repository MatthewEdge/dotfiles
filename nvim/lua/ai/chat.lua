local transport = require('ai.transport')
local context = require('ai.context')
local util = require('ai.util')

local M = {}

local state = { buf = nil, chat_id = nil, busy = false, queue = {} }

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

local function set_buffer_keymaps(buf)
    vim.keymap.set('n', '<leader>as', M.send, { buffer = buf, desc = 'Send chat message' })
    vim.keymap.set('n', '<leader>ar', M.reset, { buffer = buf, desc = 'Reset chat history' })
    vim.keymap.set('n', '<leader>af', M.refresh, { buffer = buf, desc = 'Refresh server chat state' })
end

local function open_split()
    local path = ensure_file()

    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        local win = vim.fn.win_findbuf(state.buf)[1]
        if win then
            vim.api.nvim_set_current_win(win)
        else
            vim.cmd('botright vertical sbuffer ' .. state.buf)
        end
        return state.buf
    end

    vim.cmd('botright vertical edit ' .. vim.fn.fnameescape(path))
    state.buf = vim.api.nvim_get_current_buf()
    set_buffer_keymaps(state.buf)

    return state.buf
end

local function last_user_message(lines)
    for i = #lines, 1, -1 do
        if lines[i] == YOU_MARKER then
            local content = vim.trim(table.concat(vim.list_slice(lines, i + 1), '\n'))
            if content == '' then
                return nil
            end
            return content
        elseif lines[i] == ASSISTANT_MARKER then
            return nil
        end
    end
    return nil
end

local function alternate_context()
    local altbuf = vim.fn.bufnr('#')
    local ctx = { cwd = util.project_root() }

    if altbuf == -1 or not vim.api.nvim_buf_is_valid(altbuf) then
        return ctx
    end

    local name = vim.api.nvim_buf_get_name(altbuf)
    if name == '' then
        return ctx
    end

    ctx.file = util.to_relative(name)
    ctx.content = table.concat(vim.api.nvim_buf_get_lines(altbuf, 0, -1, false), '\n')

    return ctx
end

local function append_lines(buf, lines)
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
end

local function set_last_line(buf, text)
    local last = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_buf_set_lines(buf, last - 1, last, false, { text })
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
    vim.api.nvim_buf_call(buf, function()
        vim.cmd('silent write')
    end)
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
        vim.api.nvim_buf_call(buf, function()
            vim.cmd('silent write')
        end)
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

local function send_message(buf, chat_id, req_type, message, context)
    append_lines(buf, { '', ASSISTANT_MARKER, '' })

    local streamer = { pending = '' }
    local ctx_state = { count = 0, pending_edits = {}, pending_deletes = {}, fetched = {} }

    stream_turn('/gen', {
        type = req_type,
        chat_id = chat_id,
        message = message,
        context = context,
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

M.send = function()
    local buf = open_split()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local message = last_user_message(lines)

    if not message then
        return
    end

    local context = alternate_context()

    run_or_queue(function()
        ensure_chat_id(buf, function(chat_id)
            send_message(buf, chat_id, 'chat', message, context)
        end, turn_finished)
    end)
end

M.ask = function(instruction, ctx)
    local buf = open_split()

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

        if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
            vim.api.nvim_buf_call(state.buf, function()
                vim.cmd('edit!')
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
    local buf = open_split()
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

M.open = open_split

M.toggle = function()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        local win = vim.fn.win_findbuf(state.buf)[1]
        if win then
            vim.api.nvim_win_close(win, false)
            return
        end
    end
    open_split()
end

vim.api.nvim_create_user_command('AiChat', M.open, {})
vim.api.nvim_create_user_command('AiChatReset', M.reset, {})
vim.api.nvim_create_user_command('AiChatRefresh', M.refresh, {})
vim.api.nvim_create_user_command('AiChatToggle', M.toggle, {})

vim.keymap.set('n', '<leader>at', M.toggle, { desc = 'Toggle AI chat window' })

return M
