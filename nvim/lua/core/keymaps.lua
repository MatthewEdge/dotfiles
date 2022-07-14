-----------------------------------------------------------
-- Key remappings
-----------------------------------------------------------

-- helper to allow for default options with ability to add extra options
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Change leader to spacebar
vim.g.mapleader = ' '

-----------------------------------------------------------
-- General shortcuts
-----------------------------------------------------------

-- Close all but the current buffer
map('n', '<leader>bb', ':<c-u>up <bar> %bd <bar> e#<CR>')

-- Move highlighted blocks up/down
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")

-- Window navigation & resizing
map('n', '<leader>h', ':wincmd h<CR>')
map('n', '<leader>j', ':wincmd j<CR>')
map('n', '<leader>k', ':wincmd k<CR>')
map('n', '<leader>l', ':wincmd l<CR>')
map('n', '<leader>+', ':vertical resize +5<CR>')
map('n', '<leader>-', ':vertical resize -5<CR>')
map('n', '<leader>pv', ':wincmd v<bar> :Ex <bar> :vertical resize 30<CR>')

-- Clear search highlighting with <leader> and c
map('n', '<leader>c', ':nohl<CR>')

-- Toggle auto-indenting for code paste
map('n', '<F2>', ':set invpaste paste?<CR>')
vim.opt.pastetoggle = '<F2>'

-- Change split orientation
map('n', '<leader>tk', '<C-w>t<C-w>K') -- change vertical to horizontal
map('n', '<leader>th', '<C-w>t<C-w>H') -- change horizontal to vertical

-- Move around splits using Ctrl + {h,j,k,l}
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Reload configuration without restart nvim
map('n', '<leader>r', ':so %<CR>')

-----------------------------------------------------------
-- Plugins shortcuts
-----------------------------------------------------------

-- Open Terminal as a vertical split
map('n', '<leader>tm', ':Term<CR>', { noremap = true })

-- FZF / Ripgrep
map('n', '<leader>pf', ':Files<CR>')
-- map('n', '<leader>fw', ':<C-U>execute "Rg "' . expand("<cword>") . '\| cw<CR>') -- Search for word under cursor with RipGrep

