-- Benchmark Runner runs go benchmarks in a split buffer, either for the whole
-- module or for the Benchmark func the cursor currently sits in
local ts = require('go-treesitter')

-- async, reusable output buffer
local out = require('output-buf').new()

-- run_bench streams `go test -bench` output asynchronously
local run_bench = function(pattern)
    out.run({
        'go', 'test',
        '-bench=' .. (pattern or '.'),
        '-benchmem',
        '-count=5',
        '-run=^$',
        './...',
    })
end

-- attach_to_buffer registers the benchmark user commands
local attach_to_buffer = function(bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, 'BenchFunc', function(_)
        local n = ts.get_func_method_node_at_pos(bufnr)
        if n and n.name:match('^Benchmark') then
            run_bench('^' .. n.name .. '$')
            return
        end

        run_bench()
    end, { desc = 'Run benchmark under cursor, or all benchmarks' })
end

local group = vim.api.nvim_create_augroup('benchmark-runner', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    pattern = '*.go',
    callback = function()
        vim.keymap.set('n', '<leader>rb', ':BenchFunc<CR>', { desc = 'Run benchmark under cursor' })

        local bufnr = vim.api.nvim_get_current_buf()
        attach_to_buffer(bufnr)
    end
})
