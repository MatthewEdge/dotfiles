-----------------------------------------------------------
-- Built-in Terminal settings
-----------------------------------------------------------

-- Open Terminal as a vertical split
vim.api.nvim_set_keymap('n', '<leader>tm', ':Term<CR>', { noremap = true })

-- Open a Terminal on the right tab
vim.api.nvim_create_autocmd('CmdlineEnter', {
  command = 'command! Term :botright vsplit term://$SHELL'
})

-- Enter insert mode when switching to terminal
vim.api.nvim_create_autocmd('TermOpen', {
  command = 'setlocal listchars= nonumber norelativenumber nocursorline',
})

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  command = 'startinsert'
})

-- Close terminal buffer on process exit
vim.api.nvim_create_autocmd('BufLeave', {
  pattern = 'term://*',
  command = 'stopinsert'
})
