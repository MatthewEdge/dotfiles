-- Setup lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Change leader to spacebar
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-----------------------------------------------------------
-- General keymaps
-----------------------------------------------------------

--- "ZenMode" with screen folding for the larger monitors. Toggle by reversed keymap
vim.keymap.set('n', '<leader>zm', ':setlocal foldcolumn=9 signcolumn=yes:9<CR>')
vim.keymap.set('n', '<leader>mz', ':setlocal foldcolumn=1 signcolumn=yes:1<CR>')

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

vim.o.undodir = '~/.cache/nvim/undodir' -- Move undodir to .cache
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
vim.o.laststatus = 3                    -- Set global statusline
vim.o.cmdheight = 2                     -- Add more space for bottom message

vim.o.tabstop = 4                       -- 1 tab == 4 spaces
vim.o.softtabstop = 4                   -- 1 tab == 4 spaces
vim.o.expandtab = true                  -- Use spaces instead of tabs
vim.o.shiftwidth = 4                    -- Shift 4 spaces when tab
vim.o.smartindent = true                -- Autoindent new lines
vim.o.winborder = "rounded"               -- More distinct floating windows

-- Netrw File Browser
vim.g.netrw_banner = 1                    -- on Fedora, 0 makes the terminal freak out. See https://github.com/neovim/neovim/issues/23650
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 75 -- with 25 for netrw split
-- vim.g.netrw_list_hide = 'netrw_vim.gitignore#Hide()'

-- NerdCommenter
vim.g.NERDSpaceDelims = 1
vim.g.NERDTrimTrailingWhitespace = 1

-- Require plugins last
require('plugins')
require('test-runner')
