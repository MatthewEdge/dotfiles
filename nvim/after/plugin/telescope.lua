-----------------------------------------------------------
-- Telescope config
----------------------------------------------------------
local ts = require('telescope.builtin')

vim.keymap.set('n', '<leader>pf', ts.find_files, { desc = '[P]roject [F]iles' })
vim.keymap.set('n', '<leader>rg', ts.live_grep, { desc = '[R]ip[G]rep' })
vim.keymap.set('n', '<leader>fb', ts.buffers, { desc = '[F]ind [B]uffers' })
vim.keymap.set('n', '<leader>fh', ts.help_tags, { desc = '[F]ind [H]elp Tags' })
vim.keymap.set('n', '<leader>km', ts.keymaps, { desc = '[K]ey [M]appings' })
vim.keymap.set('n', '<leader>pd', ts.diagnostics, { desc = '[P]roject [D]iagnostics' })

require('telescope').load_extension('fzf')
