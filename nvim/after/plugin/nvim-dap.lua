-----------------------------------------------------------
-- Debugging Setup
-----------------------------------------------------------

-- Plugin: nvim-dap + dap-ui and lang-specific dap extensions
local dap = require('dap')

vim.keymap.set('n', '<F3>', dap.continue)
vim.keymap.set('n', '<F2>', dap.step_over)
vim.keymap.set('n', '<F4>', dap.step_into)
vim.keymap.set('n', '<F5>', dap.step_out)
vim.keymap.set('n', '<leader>bp', dap.toggle_breakpoint)
vim.keymap.set('n', '<leader>bc', function()
    dap.set_breakpoint(vim.fn.input('Condition: '))
end)
vim.keymap.set('n', '<leader>lb', ':Telescope dap list_breakpoints', { desc = 'List Breakpoints' })
vim.keymap.set('n', '<leader>dt', ':lua require("dap-go").debug_test()<CR>', { desc = 'Debug Test' })
vim.keymap.set('n', '<leader>dui', ':lua require("dapui").toggle()<CR>', { desc = 'Debug UI' })

-- Imported from dap-go, altered to accept a Test Regex instead
local function get_arguments()
    local args = {"-test.run"}
    local co = coroutine.running()
    if co then
        return coroutine.create(function()
            vim.ui.input({ prompt = "Test Regex: " }, function(input)
                table.insert(args, input)
            end)
            coroutine.resume(co, args)
        end)
    else
        vim.ui.input({ prompt = "test Regex: " }, function(input)
            table.insert(args, input)
        end)
        return args
    end
end

require('dap-go').setup({
  dap_configurations = {
    {
      type = "go",
      name = "Debug test (Individual)",
      mode = "test",
      request = "launch",
      args = get_arguments,
      program = "./${relativeFileDirname}",
      outputMode = "remote",
    },
  }
})

-- Note: this expects a pyenv environment
require('dap-python').setup('python')
require('dap-python').test_runner = 'pytest'
vim.api.nvim_create_autocmd('Filetype', {
    group = vim.api.nvim_create_augroup('pydap', { clear = true }),
    pattern = { 'python', 'py' },
    callback = function()
        vim.keymap.set('n', '<F3>', require('dap-python').test_method)
        vim.keymap.set('n', '<leader>dbm', require('dap-python').test_method)
        vim.keymap.set('n', '<leader>dbc', require('dap-python').test_class)
        vim.keymap.set('n', '<leader>dbs', require('dap-python').debug_selection)
    end
})

require('dapui').setup({
    icons = { expanded = '▾', collapsed = '▸' },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { '<CR>', '<2-LeftMouse>' },
        open = 'o',
        remove = 'd',
        edit = 'e',
        repl = 'r',
        toggle = 't',
    },
    -- Expand lines larger than the window
    -- Requires >= 0.7
    expand_lines = true,
    -- Layouts define sections of the screen to place windows.
    -- The position can be 'left', 'right', 'top' or 'bottom'.
    -- The size specifies the height/width depending on position. It can be an Int
    -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
    -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
    -- Elements are the elements shown in the layout (in order).
    -- Layouts are opened in order so that earlier layouts take priority in window sizing.
    layouts = {
        {
            elements = {
                -- Elements can be strings or table with id and size keys.
                { id = 'scopes', size = 0.25 },
                'breakpoints',
                'stacks',
                'watches',
            },
            size = 40, -- 40 columns
            position = 'left',
        },
        {
            elements = {
                'repl',
            },
            size = 0.25, -- 25% of total lines
            position = 'bottom',
        },
    },
    floating = {
        max_height = nil,  -- These can be integers or a float between 0 and 1.
        max_width = nil,   -- Floats will be treated as percentage of your screen.
        border = 'single', -- Border style. Can be 'single', 'double' or 'rounded'
        mappings = {
            close = { 'q', '<Esc>' },
        },
    },
    windows = { indent = 1 },
    render = {
        max_type_length = nil, -- Can be integer or nil.
    }
})

-- Enable opening dap-ui automatically once debugging starts
local dapui = require('dapui')
dap.listeners.after.event_initialized['dapui_config'] = dapui.open
-- dap.listeners.before.event_terminated['dapui_config'] = dapui.close -- prefer keeping these up after completion
-- dap.listeners.before.event_exited['dapui_config'] = dapui.close
