-----------------------------------------------------------
-- Telescope config
----------------------------------------------------------
local ts = require('telescope.builtin')

vim.keymap.set('n', '<leader>pf', ts.find_files, { desc = 'Project Files' })
vim.keymap.set('n', '<leader>rg', ts.live_grep, { desc = 'RipGrep' })
vim.keymap.set('n', '<leader>fb', ts.buffers, { desc = 'Find Buffers' })
vim.keymap.set('n', '<leader>fh', ts.help_tags, { desc = 'Find Help Tags' })
vim.keymap.set('n', '<leader>km', ts.keymaps, { desc = 'Key Mappings' })
vim.keymap.set('n', '<leader>pd', ts.diagnostics, { desc = 'Project Diagnostics' })

require('telescope').load_extension('fzf')
