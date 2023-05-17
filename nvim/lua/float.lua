local M = {}

-- Show a floating window for debugging
M.debug_float = function(lines)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    table.insert(lines, 1, 'Test Case: ')
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)

    local opts = {
        relative = 'cursor',
        width = 50,
        height = 10,
        col = 0,
        row = 1,
        anchor = 'NW',
        style = 'minimal'
    }

    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:MyHighlight')
end

return M
