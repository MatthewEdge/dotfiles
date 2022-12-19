vim.opt.mouse = '' -- Disable mouse support
vim.opt.guicursor = '' -- No need for guicursor manipulation
vim.opt.clipboard = 'unnamed,unnamedplus' -- Copy/paste to system clipboard

vim.opt.undodir = '~/.cache/nvim/undodir' -- Move undodir to .cache
vim.opt.swapfile = false -- Don't use swapfile
vim.opt.history = 100 -- Remember N lines in history

vim.opt.hidden = true -- Enable background buffers
vim.opt.scrolloff = 8 -- Keep scroll offset for slightly less eye movement
vim.opt.lazyredraw = true -- Faster scrolling
vim.opt.synmaxcol = 240 -- Max column for syntax highlighting
vim.opt.updatetime = 50 -- ms to wait for triggering an event

vim.opt.number = true -- Show line number
vim.opt.relativenumber = true -- Relative line numbering
vim.opt.showmatch = true -- Highlight matching parenthesis
vim.opt.foldmethod = 'marker' -- Enable folding(default 'foldmarker')
vim.opt.colorcolumn = '120' -- Line length marker
vim.opt.splitright = true -- Vertical split to the right
vim.opt.splitbelow = true -- Horizontal split to the bottom

vim.opt.hlsearch = false -- Don't highlight all search items at once
vim.opt.incsearch = true -- ...but incremental highlighting of one is ok
vim.opt.ignorecase = true -- Ignore case letters when searching
vim.opt.smartcase = true -- Ignore lowercase for the whole pattern
vim.opt.linebreak = true -- Wrap on word boundary
vim.opt.termguicolors = true -- Enable 24-bit term colors
vim.opt.laststatus = 3 -- Set global statusline
vim.opt.cmdheight = 2 -- Add more space for bottom message

vim.opt.tabstop = 4 -- 1 tab == 4 spaces
vim.opt.softtabstop = 4 -- 1 tab == 4 spaces
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- Shift 4 spaces when tab
vim.opt.smartindent = true -- Autoindent new lines

-- Netrw File Browser
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 75 -- with 25 for netrw split
-- vim.g.netrw_list_hide = 'netrw_vim.gitignore#Hide()'


-- NerdCommenter
vim.g.NERDSpaceDelims = 1
vim.g.NERDTrimTrailingWhitespace = 1

-- Disable nvim intro
vim.opt.shortmess:append 'sI'
