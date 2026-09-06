-- Change leader to spacebar
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.cmd('colorscheme catppuccin')
-- vim.cmd('colorscheme habamax')
-- vim.cmd('colorscheme sorbet')

-----------------------------------------------------------
-- General keymaps
-----------------------------------------------------------

-- Prevent space from doing anything sans being the leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Close all but the current buffer
vim.keymap.set('n', '<leader>bb', ':<c-u>up <bar> %bd <bar> e#<CR>')

-- Move highlighted blocks up/down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Keep cursor centered while navigating
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Window navigation & resizing
vim.keymap.set('n', '<leader>h', ':wincmd h<CR>')
vim.keymap.set('n', '<leader>j', ':wincmd j<CR>')
vim.keymap.set('n', '<leader>k', ':wincmd k<CR>')
vim.keymap.set('n', '<leader>l', ':wincmd l<CR>')
vim.keymap.set('n', '<leader>+', ':vertical resize +5<CR>')
vim.keymap.set('n', '<leader>-', ':vertical resize -5<CR>')
vim.keymap.set('n', '<leader>pv', ':wincmd v<bar> :Ex <bar> :vertical resize 30<CR>')

-- Clear search highlighting
vim.keymap.set('n', '<leader>c', ':nohl<CR>')

-- Move around splits using Ctrl + {h,j,k,l}
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Reload configuration without restart nvim
vim.keymap.set('n', '<leader>r', ':so %<CR>')

-- Open a file in Firefox (mostly for web dev)
vim.keymap.set('n', '<leader>of', ':!firefox %<CR>')

-----------------------------------------------------------
-- Autocommand functions
-----------------------------------------------------------

-- Remember cursor position
vim.cmd [[
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END
]]

-- Remove whitespace on save for select files
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = {'*.md'},
    command = ':%s/\\s\\+$//e'
})

-- Enable spell checking for doc filetypes
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { '*.txt', '*.md', '*.tex' },
    callback = function()
        vim.o.spell = true
        vim.o.spelllang = 'en'
    end,
})

-----------------------------------------------------------
-- Editor options
-----------------------------------------------------------
vim.o.mouse = ''                        -- Disable mouse support
vim.o.guicursor = ''                    -- No need for guicursor manipulation
vim.o.clipboard = 'unnamedplus'         -- Copy/paste to system clipboard
-- TODO "+y mapped to <leader>y instead?

vim.o.undofile = true
-- vim.o.undodir = '~/.cache/nvim/undodir' -- Move undodir to .cache
vim.o.swapfile = false                  -- Don't use swapfile
vim.o.history = 100                     -- Remember N lines in history

vim.o.hidden = true                     -- Enable background buffers
vim.o.scrolloff = 8                     -- Keep scroll offset for slightly less eye movement
vim.o.lazyredraw = true                 -- Faster scrolling
vim.o.synmaxcol = 240                   -- Max column for syntax highlighting
vim.o.updatetime = 80                   -- ms to wait for triggering an event

vim.o.number = true                     -- Show line number
vim.o.relativenumber = true             -- Relative line numbering
vim.o.showmatch = true                  -- Highlight matching parenthesis
vim.o.foldmethod = 'marker'             -- Enable folding(default 'foldmarker')
vim.o.colorcolumn = '120'               -- Line length marker
vim.o.splitright = true                 -- Vertical split to the right
vim.o.splitbelow = true                 -- Horizontal split to the bottom

vim.o.hlsearch = false                  -- Don't highlight all search items at once
vim.o.incsearch = true                  -- ...but incremental highlighting of one is ok
vim.o.ignorecase = true                 -- Ignore case letters when searching
vim.o.smartcase = true                  -- Ignore lowercase for the whole pattern
vim.o.linebreak = true                  -- Wrap on word boundary
vim.o.termguicolors = true              -- Enable 24-bit term colors
vim.o.laststatus = 3                    -- Set global statusline across all splits

vim.o.tabstop = 4                       -- 1 tab == 4 spaces
vim.o.softtabstop = 4                   -- 1 tab == 4 spaces
vim.o.expandtab = true                  -- Use spaces instead of tabs
vim.o.shiftwidth = 4                    -- Shift 4 spaces when tab
vim.o.smartindent = true                -- Autoindent new lines
vim.o.winborder = "rounded"             -- More distinct floating windows

-- Require plugins last
require('find')
require('format')
require('plugins')
require('lsp')
require('test-runner')
require('benchmark-runner')

-- Netrw File Browser
vim.g.netrw_banner = 1        -- Hide banner now that we are on deb
vim.g.netrw_browse_split = 0  -- open files in previous window
vim.g.netrw_liststyle = 3     -- tree view
vim.g.netrw_winsize = 25      -- 25% for netrw split
vim.g.netrw_altv = 1          -- enable to right-split instead
vim.g.netrw_altfile = 1       -- keep the alternate file correct

vim.keymap.set("n", "<leader>pf", ":Lexplore<cr>", { silent = true })


-- Native Diagnostics in quickfix list
vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.setqflist()
	vim.cmd("copen")
end, { silent = true })
vim.keymap.set("n", "<leader>dd", function()
	vim.cmd("cclose")
end, { silent = true })
