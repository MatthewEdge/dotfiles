-- Test Runner simply runs test commands in a split buffer, tracks passes and failures,
-- and marks each test accordingly

-- TODO register commands: 
--   TestFunc - run the test the cursor currently sits in / on
--   TestFile - run tests in the given file
--   TestFailed - run only previously-failed tests
--   TestLast - re-run previously-run test commands

-- Create buffer
local bufnr = 18
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "hello", "world" })

-- Running external commands
local tests = "."
vim.fn.jobstart({ "go", "test", "-v", "./...", "-run", tests}, {
    stdout_buffered = true, -- only send full lines
    on_stdout = function (_, data)
        if data then
            vim.api.nvim_buf_set_lines(bufnr, -1, 1, false, data)
        end
    end,
    on_stderr = function(_, data)
        if data then
            vim.api.nvim_buf_set_lines(bufnr, -1, 1, false, data)
        end
    end,
})
