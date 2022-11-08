-----------------------------------------------------------
-- Autocommand functions
-----------------------------------------------------------

-- Remember cursor position
vim.cmd[[
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END
]]

-- Remove whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  command = ':%s/\\s\\+$//e'
})

-- Settings for filetypes:
-- Disable line length marker
vim.api.nvim_create_autocmd('Filetype', {
  group = vim.api.nvim_create_augroup('setLineLength', {clear = true}),
  pattern = { 'text', 'markdown', 'html', 'xhtml', 'javascript', 'typescript' },
  command = 'setlocal cc=0'
})

-- Enable spell checking for doc filetypes
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  pattern = { '*.txt', '*.md', '*.tex' },
  callback = function()
      vim.opt.spell = true
      vim.opt.spelllang = 'en'
  end,
})
