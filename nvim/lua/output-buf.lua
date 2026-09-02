-- output-buf owns a reusable vertical split that streams command output
-- asynchronously while the cursor stays in the calling buffer. Mostly
-- used for test / benchmark runner commands
local M = {}

M.new = function()
    local self = { buf = nil }

    -- open creates (or re-opens) a botright vertical new buffer. The original
    -- window regains focus once the buffer is created
    self.open = function()
        local orig_win = vim.api.nvim_get_current_win()

        if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
            vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, {})
            if not vim.fn.win_findbuf(self.buf)[1] then
                vim.cmd('botright vertical sbuffer ' .. self.buf)
                vim.api.nvim_set_current_win(orig_win)
            end
            return self.buf
        end

        vim.cmd('botright vertical new')
        self.buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_option(self.buf, 'buftype', 'nofile')
        vim.api.nvim_set_current_win(orig_win)

        return self.buf
    end

    -- append writes lines into the buffer with auto-scrolling
    self.append = function(data)
        local buf = self.buf
        vim.schedule(function()
            if not buf or not vim.api.nvim_buf_is_valid(buf) then
                return
            end
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)

            local win = vim.fn.win_findbuf(buf)[1]
            if win then
                local line_count = vim.api.nvim_buf_line_count(buf)
                vim.api.nvim_win_set_cursor(win, { line_count, 0 })
            end
        end)
    end

    -- run streams cmd into a freshly cleared output buffer so the command runs
    -- asynchronously while you keep working in your buffer.
    self.run = function(cmd, opts)
        opts = opts or {}
        self.open()
        vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, { table.concat(cmd, ' '), '', '' })

        return vim.fn.jobstart(cmd, {
            on_stdout = function(_, data)
                if opts.on_stdout then
                    opts.on_stdout(data)
                    return
                end
                self.append(data)
            end,
            on_stderr = function(_, data)
                self.append(data)
            end,
            on_exit = opts.on_exit,
        })
    end

    return self
end

return M
