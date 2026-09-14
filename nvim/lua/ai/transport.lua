local M = {}

M.base_url = 'http://127.0.0.1:8787'

-- post_stream POSTs `body` as JSON and calls `on_event` for each SSE
-- `data:` line the server sends, then `on_done` once the stream closes.
-- This is the only way the client talks to the server.
M.post_stream = function(path, body, on_event, on_done)
    local pending = ''
    local stderr = {}

    local function emit(line)
        local payload = line:match('^data:%s*(.+)$')
        if not payload then
            return
        end
        local ok, evt = pcall(vim.json.decode, payload)
        if ok then
            vim.schedule(function()
                on_event(evt)
            end)
        end
    end

    local job = vim.fn.jobstart({
        'curl', '-sS', '-N',
        '-X', 'POST', M.base_url .. path,
        '-H', 'Content-Type: application/json',
        '--data-binary', '@-',
    }, {
        on_stdout = function(_, data)
            if not data or #data == 0 then
                return
            end
            -- jobstart splits on newlines but the final element may be a
            -- partial line, so hold it back until the next chunk arrives.
            data[1] = pending .. data[1]
            pending = table.remove(data)
            for _, line in ipairs(data) do
                emit(line)
            end
        end,
        on_stderr = function(_, data)
            for _, line in ipairs(data or {}) do
                if line ~= '' then
                    table.insert(stderr, line)
                end
            end
        end,
        on_exit = function(_, code)
            vim.schedule(function()
                if code ~= 0 then
                    local message = #stderr > 0 and table.concat(stderr, '\n')
                        or ('curl exited with code ' .. code)
                    on_event({ type = 'error', message = message })
                end
                on_done()
            end)
        end,
    })

    if job <= 0 then
        vim.schedule(function()
            on_event({ type = 'error', message = 'failed to start curl' })
            on_done()
        end)
        return
    end

    vim.fn.chansend(job, vim.json.encode(body))
    vim.fn.chanclose(job, 'stdin')
end

return M
