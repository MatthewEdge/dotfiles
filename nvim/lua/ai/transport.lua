local M = {}

M.base_url = 'http://127.0.0.1:8787'

local function parse_sse_lines(lines, on_event)
    for _, line in ipairs(lines) do
        local payload = line:match('^data:%s*(.+)$')
        if payload then
            local ok, decoded = pcall(vim.json.decode, payload)
            if ok then
                on_event(decoded)
            end
        end
    end
end

M.post_stream = function(path, body, on_event, on_done)
    local cmd = {
        'curl', '-sS', '-N',
        '-X', 'POST', M.base_url .. path,
        '-H', 'Content-Type: application/json',
        '--data-binary', '@-',
    }

    local pending = ''
    local stderr_lines = {}

    local job = vim.fn.jobstart(cmd, {
        on_stdout = function(_, data)
            if not data or #data == 0 then
                return
            end

            data[1] = pending .. data[1]
            pending = table.remove(data)

            if #data > 0 then
                parse_sse_lines(data, function(evt)
                    vim.schedule(function()
                        on_event(evt)
                    end)
                end)
            end
        end,
        on_stderr = function(_, data)
            for _, line in ipairs(data or {}) do
                if line ~= '' then
                    table.insert(stderr_lines, line)
                end
            end
        end,
        on_exit = function(_, code)
            vim.schedule(function()
                if code ~= 0 and #stderr_lines > 0 then
                    on_event({ type = 'error', message = table.concat(stderr_lines, '\n') })
                end
                if on_done then
                    on_done(code)
                end
            end)
        end,
    })

    if job <= 0 then
        vim.schedule(function()
            on_event({ type = 'error', message = 'failed to start curl (job id ' .. job .. ')' })
            if on_done then
                on_done(-1)
            end
        end)
        return nil
    end

    vim.fn.chansend(job, vim.json.encode(body))
    vim.fn.chanclose(job, 'stdin')

    return job
end

M.get = function(path, on_response)
    local cmd = { 'curl', '-sS', M.base_url .. path }
    local chunks = {}

    local job = vim.fn.jobstart(cmd, {
        on_stdout = function(_, data)
            for _, line in ipairs(data or {}) do
                table.insert(chunks, line)
            end
        end,
        on_exit = function(_, code)
            vim.schedule(function()
                if code ~= 0 then
                    on_response(nil, 'curl exited with code ' .. code)
                    return
                end

                local ok, decoded = pcall(vim.json.decode, table.concat(chunks, '\n'))
                if not ok then
                    on_response(nil, 'failed to decode response')
                    return
                end

                on_response(decoded, nil)
            end)
        end,
    })

    if job <= 0 then
        vim.schedule(function()
            on_response(nil, 'failed to start curl (job id ' .. job .. ')')
        end)
        return nil
    end

    return job
end

M.post = function(path, body, on_response)
    local cmd = {
        'curl', '-sS',
        '-X', 'POST', M.base_url .. path,
        '-H', 'Content-Type: application/json',
        '--data-binary', '@-',
    }
    local chunks = {}

    local job = vim.fn.jobstart(cmd, {
        on_stdout = function(_, data)
            for _, line in ipairs(data or {}) do
                table.insert(chunks, line)
            end
        end,
        on_exit = function(_, code)
            vim.schedule(function()
                if code ~= 0 then
                    on_response(nil, 'curl exited with code ' .. code)
                    return
                end

                local ok, decoded = pcall(vim.json.decode, table.concat(chunks, '\n'))
                if not ok then
                    on_response(nil, 'failed to decode response')
                    return
                end

                on_response(decoded, nil)
            end)
        end,
    })

    if job <= 0 then
        vim.schedule(function()
            on_response(nil, 'failed to start curl (job id ' .. job .. ')')
        end)
        return nil
    end

    vim.fn.chansend(job, vim.json.encode(body))
    vim.fn.chanclose(job, 'stdin')

    return job
end

return M
