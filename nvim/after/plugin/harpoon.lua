local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = '[H]arpoon [A]dd file'})
vim.keymap.set("n", "<leader>hr", mark.rm_file, { desc = '[H]arpoon [R]emove file'})
vim.keymap.set("n", "<leader>he", ui.toggle_quick_menu, {desc = 'Harpoon Menu'})

vim.keymap.set("n", "<C-u>", function() ui.nav_file(1) end)
vim.keymap.set("n", "<C-i>", function() ui.nav_file(2) end)
vim.keymap.set("n", "<C-o>", function() ui.nav_file(3) end)
vim.keymap.set("n", "<C-p>", function() ui.nav_file(4) end)
