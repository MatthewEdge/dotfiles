-----------------------------------------------------------
-- Debugging Setup
-----------------------------------------------------------

-- Plugin: nvim-dap + dap-ui and lang-specific dap extensions

vim.keymap.set('n', '<F1>', ':lua require("dap").continue()<CR>')
vim.keymap.set('n', '<F2>',  ':lua require("dap").toggle_breakpoint()<CR>')
vim.keymap.set('n', '<F3>', ':lua require("dap").step_over()<CR>')
vim.keymap.set('n', '<F4>', ':lua require("dap").step_into()<CR>')
vim.keymap.set('n', '<leader>dt', ':lua require("dap-go").debug_test()<CR>')

require('dap-go').setup()
require('dapui').setup()

vim.keymap.set('n', '<leader>dui', ':lua require("dapui").toggle()<CR>')
