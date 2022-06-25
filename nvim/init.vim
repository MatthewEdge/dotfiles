set nocompatible
syntax on " Enable syntax highlighting
filetype plugin indent on

let mapleader=' '

set hidden
set nospell " disable spell check
set noerrorbells novisualbell " disable annoying bells
set relativenumber number " jump line numbers with line number for current line
set encoding=utf-8 fileencoding=utf-8 " standardize utf-8
set noswapfile nobackup nowritebackup " no swp / bak files
set hlsearch " enable search highlight
set incsearch " highlight searches while being yped
set ignorecase smartcase " ignore casing in search
set smartindent " Enable smart indentation
set expandtab " expand tabs to spaces
set tabstop=2 shiftwidth=2 " Tabs == 2 spaces
set nowrap linebreak
set colorcolumn=120
set formatoptions+=j " Delete comment character when joining commented lines
set backspace=indent,eol,start " Allow backspace in insert mode
set undofile undodir=~/.vim/undodir " Maintain undo history between sessions
set clipboard^=unnamed,unnamedplus " Enable cross-app copy/paste after vim yank/paste

set title " Show filename in window title bar
set noshowmode " Do not show mode on command line since vim-airline can show it
set cmdheight=2 " Space for bottom messages
set shortmess+=c " Don't pass messages to ins-completion-menu
set scrolloff=3 " Start scrolling 3 lines before horizontal window border

set ttyfast " Optimize for fast terminal connections
set updatetime=50

set wildmenu wildmode=list:longest,full " Command-line completion in enhanced mode

" trim trailing whitespace pre-save
autocmd BufWritePre * %s/\s\+$//e

" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" Plugins
" Install with curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
call plug#begin('~/.vim/plugged')

" LSP Config enablement
" Plug 'neovim/nvim-lspconfig'

" Color Scheme
Plug 'morhetz/gruvbox'

" QoL
Plug 'preservim/nerdcommenter'
Plug 'vim-airline/vim-airline'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() }}
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

" Language Syntax
Plug 'sheerun/vim-polyglot'

" Postgres
" Plug 'lifepillar/pgsql.vim'

" Go
Plug 'fatih/vim-go', {'do': ':GoUpdateBinaries'}

call plug#end()

" Color Scheme
colorscheme gruvbox
set background=dark
" let g:gruvbox_contrast_dark = 'hard'
if exists('+termguicolors')
  let &t_8f = '\<Esc>[38;2;%lu;%lu;%lum'
  let &t_8b = '\<Esc>[48;2;%lu;%lu;%lum'
endif
let g:gruvbox_invert_selection='0'

" Ripgrep
if executable('rg')
  let g:rg_derive_root='true'
endif

" FZF
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
let $FZF_DEFAULT_COMMAND="rg --hidden -l -g '!{.git}' --sort path ."
let $FZF_DEFAULT_OPTS='--reverse' " Search at top, results below

" FileBrowser w/ Netrw
let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_winsize = 75 " with 25 for netrw split
let g:netrw_list_hide=netrw_gitignore#Hide()

" NerdCommenter
let g:NERDSpaceDelims=1
let g:NERDTrimTrailingWhitespace=1

" Remaps

" Close all but the current buffer
nnoremap <leader>bd :<c-u>up <bar> %bd <bar> e#<cr>

" Search for word under cursor with RipGrep
nnoremap <leader>fw :<C-U>execute "Rg ".expand('<cword>') \| cw<CR>
nnoremap <leader>rg :Rg<CR>

" Window navigation & resizing
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>+ :vertical resize +5<CR>
nnoremap <leader>- :vertical resize -5<CR>
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>

" fzf files view
nnoremap <leader>pf :Files<CR>

" Move highlighted blocks up/down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Open in Firefox
nnoremap <leader>of :!open -a Firefox %<CR><CR>

" vim-fugitive
nnoremap <C-p> :GFiles<CR>
nnoremap <leader>ga :Git fetch --all<CR>
nnoremap <leader>gc :GCheckout<CR>
nmap <leader>gs :G<CR>
" Get left side diff fragment
nmap <leader>gf :diffget //2<CR>
" Get right side diff fragment
nmap <leader>gh :diffget //3<CR>

" Go
augroup filetype_go
  autocmd!

  " Set formatting to match Go compiler
  autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

  " shortcut go error
  nnoremap <Leader>ee oif err != nil {<CR>log.Fatalf("%+v\n", err)<CR>}<CR><esc>kkI<esc>

  " Add tags quick
  nnoremap <leader>at :GoAddTags<CR>
  nnoremap <leader>atd :GoAddTags db<CR>

  " Navigations
  nnoremap <leader>gd :GoDef<CR>
  nnoremap <leader>gr :GoReferrers<CR>
  nnoremap <leader>gi :GoImplements<CR>

  " Testing
  nnoremap <leader>rt :GoTestFunc<CR>
  nnoremap <leader>tc :GoCoverage<CR>
  nnoremap <leader>cc :GoCoverageClear<CR>

  " Renaming
  nnoremap <leader>rr :GoRename

  " Debug shortcuts
  nnoremap <leader>bp :GoDebugBreakpoint<CR>
  nnoremap <leader>dn :GoDebugContinue<CR>

  " we leave this hanging for flag input
  nnoremap <leader>dbs :GoDebugStart
  nnoremap <leader>dbe :GoDebugStop<CR>
augroup END

" vim-go
let g:go_def_mapping_enabled = 0
let g:go_auto_type_info = 1
let g:go_auto_sameids = 1
let g:go_debug_windows = {
      \ 'vars':       'rightbelow 40vnew',
      \ 'stack':      'rightbelow 10new',
\ }

let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_format_strings = 1
let g:go_highlight_variable_declarations = 1
