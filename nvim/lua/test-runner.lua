-- Test Runner simply runs test commands in a split buffer, tracks passes and failures,
-- and marks each test accordingly
local util = require('go-treesitter')

-- TODO register commands: 
--   TestFunc - run the test the cursor currently sits in / on
--   TestFile - run tests in the given file
--   TestFailed - run only previously-failed tests
--   TestLast - re-run previously-run test commands
local create_cmd = function(cmd, func, opt)
  opt = vim.tbl_extend('force', { desc = 'go.nvim ' .. cmd }, opt or {})
  vim.api.nvim_create_user_command(cmd, func, opt)
end

local debug_float = function(lines)
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

create_cmd('RunTest', function(_)
    local buf = vim.api.nvim_get_current_buf()
    local ns = util.get_func_method_node_at_pos(buf)
    if ns == nil then
        print('No test func found')
        return
    end

    local func = ns.name
    print(func)
end)

vim.keymap.set('n', '<leader>rt', ':RunTest<CR>', { desc = 'Run Test under cursor' })

-- -- Running external commands
-- local tests = '.'
-- vim.fn.jobstart({ 'go', 'test', '-v', '-json', './...', '-run', tests}, {
    -- stdout_buffered = true, -- only send full lines
    -- on_stdout = function (_, data)
        -- if data then
            -- vim.api.nvim_buf_set_lines(bufnr, -1, 1, false, data)
        -- end
    -- end,
    -- on_stderr = function(_, data)
        -- if data then
            -- vim.api.nvim_buf_set_lines(bufnr, -1, 1, false, data)
        -- end
    -- end,
-- })
