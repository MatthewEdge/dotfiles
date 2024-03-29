local mark = require('harpoon.mark')
local ui = require('harpoon.ui')

vim.keymap.set('n', '<leader>ha', mark.add_file, { desc = 'Harpoon Add file'})
vim.keymap.set('n', '<leader>hr', mark.rm_file, { desc = 'Harpoon Remove file'})
vim.keymap.set('n', '<leader>he', ui.toggle_quick_menu, {desc = 'Harpoon Menu'})

vim.keymap.set('n', '<C-y>', function() ui.nav_file(1) end)
vim.keymap.set('n', '<C-u>', function() ui.nav_file(2) end)
