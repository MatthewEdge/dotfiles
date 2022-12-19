-----------------------------------------------------------
-- Telescope config
----------------------------------------------------------
ts = require('telescope.builtin')

vim.keymap.set('n', '<leader>pf', ts.find_files)
vim.keymap.set('n', '<C-p>', ts.git_files)
vim.keymap.set('n', '<leader>rg', ts.live_grep)
vim.keymap.set('n', '<leader>fb', ts.buffers)
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>')
vim.keymap.set('n', '<leader>pd', ts.diagnostics)

require('telescope').load_extension('fzf')
