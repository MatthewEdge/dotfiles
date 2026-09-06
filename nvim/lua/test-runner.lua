-- Test Runner simply runs test commands in a split buffer, tracks passes and failures,
-- and marks each test accordingly
local ts = require('go-treesitter')

-- out owns the test-output split so a new run reuses and clears it instead
-- of stacking splits to the right
local out = require('output-buf').new()

-- run_tests streams `go test -json` into the output buffer as it arrives and
-- collects diagnostics for any failures. tests can be omitted to run all.
local run_tests = function(bufnr, ns, tests)
    vim.diagnostic.reset(ns, bufnr)

    local command = { 'go', 'test', '-v', '-json' }
    if tests and #tests > 0 then
        table.insert(command, '-run')
        table.insert(command, table.concat(tests, '|'))
    end
    table.insert(command, './...')

    local failed = {}
    local seen = {}

    -- add_failure records a diagnostic for the failing test, keyed by line so
    -- a failing sub-test doesn't stack a second marker on its parent
    local add_failure = function(name)
        local parent = name:match('^[^/]+')
        local line = ts.get_test_line(bufnr, parent)
        if not line or line < 0 or seen[line] then
            return
        end
        seen[line] = true

        table.insert(failed, {
            bufnr = bufnr,
            lnum = line,
            col = 0,
            severity = vim.diagnostic.severity.ERROR,
            source = 'go-test',
            message = 'Test Failed: ' .. name,
            user_data = {},
        })
    end

    -- partial holds the tail of a chunk that ended mid-line, since streaming
    -- means json objects can be split across two callbacks
    local partial = ''

    out.run(command, {
        on_stdout = function(data)
            if not data or #data == 0 then
                return
            end

            data[1] = partial .. data[1]
            partial = table.remove(data)

            local lines = {}
            for _, line in ipairs(data) do
                local ok, d = pcall(vim.json.decode, line)
                if ok and type(d) == 'table' then
                    if d.Action == 'output' and d.Output then
                        table.insert(lines, (d.Output:gsub('\n$', '')))
                    elseif d.Action == 'fail' and d.Test then
                        add_failure(d.Test)
                    end
                end
            end

            if #lines > 0 then
                out.append(lines)
            end
        end,
        on_exit = function()
            -- Add diagnostics for failed tests so we see them in Telescope
            vim.diagnostic.set(ns, bufnr, failed, {})
        end,
    })
end

-- Enable test commands
local ns = vim.api.nvim_create_namespace('test-runner')
local group = vim.api.nvim_create_augroup('test-runner', { clear = true })

vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    pattern = '*.go',
    callback = function()
        vim.keymap.set('n', '<leader>rt', ':TestFunc<CR>', { desc = 'Run Test under cursor' })

        local bufnr = vim.api.nvim_get_current_buf()

        -- Run only the test under the cursor
        vim.api.nvim_buf_create_user_command(bufnr, 'TestFunc', function(_)
            local n = ts.get_func_method_node_at_pos(bufnr)
            if n == nil then
                print('No test func found. Running all')
                run_tests(bufnr, ns)
                return
            end

            run_tests(bufnr, ns, { n.name })
        end, { desc = 'Run test under cursor' })
    end
})
