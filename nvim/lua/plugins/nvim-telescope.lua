-- Telescope
ts = require('telescope.builtin')

opts = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>pf', ts.find_files, opts)
vim.keymap.set('n', '<leader>rg', ts.live_grep, opts)
vim.keymap.set('n', '<leader>fb', ts.buffers, opts)
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>')

-- ts.load_extension('fzf')
-- ts.load_extension('file_browser')
