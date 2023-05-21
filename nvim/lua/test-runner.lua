-- Test Runner simply runs test commands in a split buffer, tracks passes and failures,
-- and marks each test accordingly
local ts = require('go-treesitter')

-- make_key is a simple helper to create keys for test state
local make_key = function(entry)
    assert(entry.Package, 'Must have Package key: ' .. vim.inspect(entry))
    assert(entry.Test, 'Must have Test key: ' .. vim.inspect(entry))
    return string.format('%s/%s', entry.Package, entry.Test)
end

-- split_tests identifies and separates sub-tests from root tests
local split_tests = function (test)
    local parts = {}
    local n = 1
    for w in test:gmatch('([^/]*)') do
        parts[n] = parts[n] or w -- to skip the blanks
        if w == "" then
            n = n + 1
        end
    end
    return parts
end

-- add_test upserts a test to the table. If the test spawns subtests then
-- the line number will be set to the parent test
local add_test = function(state, entry)
    local parts = split_tests(entry.Test)
    local parent = entry.Test
    if table.maxn(parts) > 1 then
        -- Sub-test identified. Use the parent for extmarks
        parent = parts[1]
    end

    local key = make_key(entry)
    state.tests[key] = {
        name = entry.Test,
        line = ts.get_test_line(state.bufnr, parent),
        output = {},
    }
end

-- add_test_output collects output lines for the given test
local add_test_output = function(state, entry)
    assert(state.tests, vim.inspect(state))
    table.insert(state.tests[make_key(entry)].output, vim.trim(entry.Output))
end

-- mark_status marks whether the test passed or failed
local mark_status = function(state, entry)
    assert(state.tests, vim.inspect(state))
    state.tests[make_key(entry)].success = (entry.Action == 'pass')
end

-- run_tests calls out to go test, parses the output, and stores results in given state
-- tests param can be omitted to run all tests
local run_tests = function(bufnr, ns, state, tests)
    -- clear previous extmarks & test state
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    -- TODO allow for no test to be passed
    local command = { 'go', 'test', '-v', '-json', './...'}
    if tests then
        local tests_regex = table.concat(tests, "|")
        table.insert(command, '-run')
        table.insert(command, tests_regex)
    end

    vim.fn.jobstart(command, {
        stdout_buffered = true, -- only send full lines on_stdout = function(_, data)
        on_stdout = function(_, data)
            if not data then
                return
            end
            for _, line in ipairs(data) do
                local d = vim.json.decode(line)
                if d == nil then return end

                if d.Action == 'run' then
                    add_test(state, d)
                elseif d.Action == 'output' then
                    if not d.Test then
                        return
                    end
                    add_test_output(state, d)
                elseif d.Action == 'pass' or d.Action == 'fail' then
                    mark_status(state, d)

                    -- Add extmark for test status
                    local test = state.tests[make_key(d)]
                    if not test.line or test.line < 0 then
                        -- No line number found? Don't fail miserably
                        return
                    end
                    if test.success then
                        vim.api.nvim_buf_set_extmark(bufnr, ns, test.line, 0, { virt_text = {{ "✓" }}})
                    elseif not test.success then
                        vim.api.nvim_buf_set_extmark(bufnr, ns, test.line, 0, { virt_text = {{ "x" }}})
                    end
                else
                    print('Skipping unknown line: ' .. vim.inspect(data))
                end
            end
        end,
        on_exit = function()
            -- Add diagnostics for failed tests so we see them in Telescope
            local failed = {}
            for _, test in pairs(state.tests) do
                if test.line then
                    if not test.success then
                        table.insert(failed, {
                            bufnr = bufnr,
                            lnum = test.line,
                            col = 0,
                            severity = vim.diagnostic.severity.ERROR,
                            source = "go-test",
                            message = "Test Failed",
                            user_data = {},
                        })
                    end
                end
            end

            vim.diagnostic.set(ns, bufnr, failed, {})
        end,
    })
end


local state = {
    -- bufnr = bufnr,
    tests = {},
}

-- attach_to_buffer manages test state and registering user commands
local attach_to_buffer = function(bufnr, ns)
    state.bufnr = bufnr

    -- Run only the test under the cursor
    vim.api.nvim_buf_create_user_command(bufnr, 'TestFunc', function(_)
        local n = ts.get_func_method_node_at_pos(bufnr)
        if n == nil then
            print('No test func found')
            return
        end

        run_tests(bufnr, ns, state, {n.name})
    end, { desc = 'Run test under cursor' })

    -- TODO need to fix this one's args
    vim.api.nvim_buf_create_user_command(bufnr, 'TestOnly', function(args)
        print(args)
    end, { desc = 'Run specified tests only' })

    -- Get associated Test Output
    vim.api.nvim_buf_create_user_command(bufnr, "TestOutput", function()
        local line = 0

        -- try fetching nearest test line num
        local n = ts.get_func_method_node_at_pos(bufnr)
        if n == nil then
            line = vim.fn.line "." - 1
        else
            line = ts.get_test_line(bufnr, n.name)
        end

        -- TODO don't create split if no output
        -- Create a split for the output
        vim.cmd('botright vertical new')
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
        for _, test in pairs(state.tests) do
            if test.line == line then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, test.output)
            end
        end
    end, { desc = 'Get output for test under cursor' })
end

-- Enable test commands
local ns = vim.api.nvim_create_namespace('test-runner')
local group = vim.api.nvim_create_augroup('test-runner', { clear = true })

vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    pattern = '*.go',
    callback = function()
        vim.keymap.set('n', '<leader>rt', ':TestFunc<CR>', { desc = 'Run Test under cursor' })
        vim.keymap.set('n', '<leader>to', ':TestOutput<CR>', { desc = 'Get stored test output' })

        -- Allow state to persist between runs
        local bufnr = vim.api.nvim_get_current_buf()

        attach_to_buffer(bufnr, ns)
    end
})
