-- Don't interfere with nvim-cmp
-- vim.g.copilot_no_tab_map = true
-- vim.g.copilot_assume_mapped = true

-- vim.keymap.set('i', '<C-a>', vim.fn['copilot#Accept()'])
vim.keymap.set('i', '<C-j>', '<Plug>(copilot-next)')
vim.keymap.set('i', '<C-k>', '<Plug>(copilot-previous)')
vim.keymap.set('i', '<C-|>', '<Plug>(copilot-next)')
