-----------------------------------------------------------
-- Autocommand functions
-----------------------------------------------------------

-- Define autocommands with Lua APIs (mostly)

-- Remember cursor position
vim.cmd[[
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END
]]

-- Maybe one day I'll figure out how to do ^ in pure Lua
-- autocmd('BufReadPost', {
    -- group = "vimrc-remember-cursor-position",
    -- callback = function()
        -- if vim.api.line("'\"") > 1 and vim.api.line("'\"") <= vim.api.line("$") then
            -- vim.cmd("normal! g`\"")
        -- end
    -- end
-- })

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
