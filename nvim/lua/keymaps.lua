-----------------------------------------------------------
-- Key remappings
-----------------------------------------------------------

-- Change leader to spacebar
vim.g.mapleader = '<Space>'

-----------------------------------------------------------
-- General shortcuts
-----------------------------------------------------------

local opts = { noremap = true }

-- Renaming shortcut
vim.api.nvim_set_keymap('n', '<leader>rr', 'gD:%s/<C-R>///gc<left><left><left>', opts)

-- Close all but the current buffer
vim.api.nvim_set_keymap('n', '<leader>bb', ':<c-u>up <bar> %bd <bar> e#<CR>', opts)

-- Move highlighted blocks up/down
vim.api.nvim_set_keymap('v', 'J', ":m '>+1<CR>gv=gv", opts)
vim.api.nvim_set_keymap('v', 'K', ":m '<-2<CR>gv=gv", opts)

-- Window navigation & resizing
vim.api.nvim_set_keymap('n', '<leader>h', ':wincmd h<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>j', ':wincmd j<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>k', ':wincmd k<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>l', ':wincmd l<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>+', ':vertical resize +5<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>-', ':vertical resize -5<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>pv', ':wincmd v<bar> :Ex <bar> :vertical resize 30<CR>', opts)

-- Clear search highlighting with <leader> and c
vim.api.nvim_set_keymap('n', '<leader>c', ':nohl<CR>', opts)

-- Change split orientation
vim.api.nvim_set_keymap('n', '<leader>tk', '<C-w>t<C-w>K', opts) -- change vertical to horizontal
vim.api.nvim_set_keymap('n', '<leader>th', '<C-w>t<C-w>H', opts) -- change horizontal to vertical

-- Move around splits using Ctrl + {h,j,k,l}
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', opts)
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', opts)
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', opts)
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', opts)

-- Reload configuration without restart nvim
vim.api.nvim_set_keymap('n', '<leader>r', ':so %<CR>', opts)
