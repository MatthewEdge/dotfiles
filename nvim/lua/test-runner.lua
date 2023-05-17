-- Test Runner simply runs test commands in a split buffer, tracks passes and failures,
-- and marks each test accordingly
local ts = require('go-treesitter')

-- local tests = '.'
local run_tests = function(tests)
    local tests_regex = table.concat(tests, "|")

    vim.cmd('botright vertical new')
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, tests)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')


    -- TODO smarter go test building
    vim.fn.jobstart({ 'go', 'test', '-v', '-json', './...', '-run', tests_regex}, {
        stdout_buffered = true, -- only send full lines
        on_stdout = function (_, data)
            if data then
                vim.api.nvim_buf_set_lines(buf, -1, 1, false, data)
            end
        end,
        on_stderr = function(_, data)
            if data then
                vim.api.nvim_buf_set_lines(buf, -1, 1, false, data)
            end
        end,
    })
end

local create_cmd = function(cmd, func, opt)
  opt = vim.tbl_extend('force', { desc = 'test-runner ' .. cmd }, opt or {})
  vim.api.nvim_create_user_command(cmd, func, opt)
end

-- TODO register commands: 
--   TestFunc - run the test the cursor currently sits in / on
--   TestFile - run tests in the given file
--   TestFailed - run only previously-failed tests
--   TestLast - re-run previously-run test commands
create_cmd('TestFunc', function(_)
    local buf = vim.api.nvim_get_current_buf()
    local ns = ts.get_func_method_node_at_pos(buf)
    if ns == nil then
        print('No test func found')
        return
    end

    local func = ns.name
    run_tests({func})
end)

vim.keymap.set('n', '<leader>rt', ':TestFunc<CR>', { desc = 'Run Test under cursor' })
