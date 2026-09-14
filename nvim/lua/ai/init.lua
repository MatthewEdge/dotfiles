-- An AI chat harness whose entire session state is a markdown file.
--
-- CHAT-HISTORY.md is the conversation. It is sent to the server on every
-- turn and the server keeps nothing between requests, so editing the file
-- edits the conversation: delete an exchange the model got wrong, prune a
-- pasted blob that is eating context, copy the file to branch the chat.
local fs = require('ai.fs')
local transport = require('ai.transport')

local M = {}

local YOU = '## you'
local MODEL = '## model'

local state = { buf = nil, busy = false }

local function history_path()
    return fs.root() .. '/CHAT-HISTORY.md'
end

local function text_of(buf)
    return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
end

local function append(buf, lines)
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
end

local function save(buf)
    vim.api.nvim_buf_call(buf, function()
        vim.cmd('silent write')
    end)
end

-- ensure_window opens (or reuses) the transcript split. It does not steal
-- focus when the split is already visible somewhere.
local function ensure_window()
    local path = history_path()
    if vim.fn.filereadable(path) == 0 then
        vim.fn.writefile({ YOU, '' }, path)
    end

    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        if not vim.fn.win_findbuf(state.buf)[1] then
            vim.cmd('botright vertical sbuffer ' .. state.buf)
        end
        return state.buf
    end

    vim.cmd('botright vertical split ' .. vim.fn.fnameescape(path))
    state.buf = vim.api.nvim_get_current_buf()
    return state.buf
end

-- context reports what the user is looking at, optionally narrowed to a
-- line range. The server decides what to do with it.
local function context(range)
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)
    if name == '' then
        return nil
    end

    return { file = fs.relative(name), content = text_of(buf), selection = range }
end

-- render rewrites the model's reply in place. Accumulating the whole reply
-- and redrawing from `start` avoids any partial-line bookkeeping.
local function render(buf, start, reply)
    vim.api.nvim_buf_set_lines(buf, start, -1, false, vim.split(reply, '\n', { plain = true }))
end

-- stream runs one leg of a turn. The server streams text until it needs
-- the filesystem; then it sends an `fs` event and ends the stream, and we
-- answer by opening the next leg with the result. A turn is however many
-- legs that takes -- the server decides when to stop asking.
local function stream(buf, start, acc, path, body)
    local request

    transport.post_stream(path, body, function(evt)
        if evt.type == 'text_delta' then
            acc.reply = acc.reply .. evt.text
            render(buf, start, acc.reply)
        elseif evt.type == 'fs' then
            request = evt
        elseif evt.type == 'error' then
            acc.reply = acc.reply .. '\n\n**error:** ' .. evt.message .. '\n'
            render(buf, start, acc.reply)
        end
    end, function()
        if not request then
            append(buf, { '', YOU, '' })
            save(buf)
            state.busy = false
            return
        end

        -- Filesystem traffic is deliberately kept out of the transcript:
        -- a file snapshot from five turns ago would only mislead the model
        -- later, and re-asking is cheap.
        vim.notify('AI: ' .. fs.summary(request))
        local result = fs.run(request)
        stream(buf, start, acc, '/fs', {
            cwd = fs.root(),
            id = request.id,
            ok = result.ok,
            content = result.content,
        })
    end)
end

local function send(message, ctx)
    if state.busy then
        vim.notify('AI: busy', vim.log.levels.WARN)
        return
    end
    state.busy = true

    local buf = ensure_window()
    local lines = { '', YOU }
    vim.list_extend(lines, vim.split(message, '\n', { plain = true }))
    append(buf, lines)

    -- The transcript's last `## you` section is the message, so there is
    -- nothing to send twice. Snapshot it before adding the reply header.
    local body = { cwd = fs.root(), transcript = text_of(buf), context = ctx }

    append(buf, { '', MODEL, '' })
    stream(buf, vim.api.nvim_buf_line_count(buf) - 1, { reply = '' }, '/gen', body)
end

local compose_seq = 0

-- send opens a scratch float for a multi-line message. `:w`/`:wq`/`ZZ`
-- send it via buftype=acwrite's BufWriteCmd (the idiom fugitive uses for
-- commit messages); `:q!` cancels. All of those already require normal
-- mode, so there is no mode-switch dance.
M.send = function()
    local return_win = vim.api.nvim_get_current_win()
    local ctx = context(nil)

    compose_seq = compose_seq + 1
    local buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(buf, 'aichat://compose/' .. compose_seq)
    vim.bo[buf].buftype = 'acwrite'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = 'markdown'

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
        title = ' Ask AI  (:wq send, :q! cancel) ',
        title_pos = 'center',
    })

    -- Restore focus however the float ended up closing.
    vim.api.nvim_create_autocmd('WinClosed', {
        pattern = tostring(win),
        once = true,
        callback = function()
            if vim.api.nvim_win_is_valid(return_win) then
                vim.api.nvim_set_current_win(return_win)
            end
        end,
    })

    vim.api.nvim_create_autocmd('BufWriteCmd', {
        buffer = buf,
        callback = function()
            local message = vim.trim(text_of(buf))
            -- Clear before unsetting 'modified': set_lines re-dirties the
            -- buffer, and :wq's quit step would then refuse to close.
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '' })
            vim.bo[buf].modified = false
            if message ~= '' then
                send(message, ctx)
            end
        end,
    })

    vim.cmd('startinsert')
end

local function ask(range)
    local ctx = context(range)
    local prompt = range and 'Ask about selection: ' or 'Ask about file: '

    vim.ui.input({ prompt = prompt }, function(instruction)
        if instruction and vim.trim(instruction) ~= '' then
            send(instruction, ctx)
        end
    end)
end

M.ask_file = function()
    ask(nil)
end

M.ask_selection = function()
    local buf = vim.api.nvim_get_current_buf()
    ask({
        start_line = vim.api.nvim_buf_get_mark(buf, '<')[1],
        end_line = vim.api.nvim_buf_get_mark(buf, '>')[1],
    })
end

-- reset is purely local: the server holds no session to clear.
M.reset = function()
    local buf = ensure_window()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { YOU, '' })
    save(buf)
end

M.open = ensure_window

M.toggle = function()
    local win = state.buf
        and vim.api.nvim_buf_is_valid(state.buf)
        and vim.fn.win_findbuf(state.buf)[1]

    if win then
        pcall(vim.api.nvim_win_close, win, false)
    else
        ensure_window()
    end
end

vim.api.nvim_create_user_command('AiChat', M.open, {})
vim.api.nvim_create_user_command('AiChatToggle', M.toggle, {})
vim.api.nvim_create_user_command('AiChatReset', M.reset, {})

vim.keymap.set('n', '<leader>as', M.send, { desc = 'Compose AI chat message' })
vim.keymap.set('n', '<leader>at', M.toggle, { desc = 'Toggle AI chat window' })
vim.keymap.set('n', '<leader>ar', M.reset, { desc = 'Reset chat history' })
vim.keymap.set('n', '<leader>ae', M.ask_file, { desc = 'Ask AI about file' })
vim.keymap.set('v', '<leader>ae', M.ask_selection, { desc = 'Ask AI about selection' })

return M
