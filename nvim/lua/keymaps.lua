-----------------------------------------------------------
-- Key remappings
-----------------------------------------------------------

-- Change leader to spacebar
vim.g.mapleader = ' '

-- If, for some reason, autoformat is off
vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format()
end)

-----------------------------------------------------------
-- General shortcuts
-----------------------------------------------------------

-- Close all but the current buffer
vim.keymap.set('n', '<leader>bb', ':<c-u>up <bar> %bd <bar> e#<CR>')

-- Move highlighted blocks up/down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Keep cursor centered while navigating
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Window navigation & resizing
vim.keymap.set('n', '<leader>h', ':wincmd h<CR>')
vim.keymap.set('n', '<leader>j', ':wincmd j<CR>')
vim.keymap.set('n', '<leader>k', ':wincmd k<CR>')
vim.keymap.set('n', '<leader>l', ':wincmd l<CR>')
vim.keymap.set('n', '<leader>+', ':vertical resize +5<CR>')
vim.keymap.set('n', '<leader>-', ':vertical resize -5<CR>')
vim.keymap.set('n', '<leader>pv', ':wincmd v<bar> :Ex <bar> :vertical resize 30<CR>')

-- Clear search highlighting with <leader> and c
vim.keymap.set('n', '<leader>c', ':nohl<CR>')

-- Move around splits using Ctrl + {h,j,k,l}
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Reload configuration without restart nvim
vim.keymap.set('n', '<leader>r', ':so %<CR>')

-- Auto chmod a file from within vim <3
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
