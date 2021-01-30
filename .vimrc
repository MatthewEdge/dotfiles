set nocompatible
syntax on
filetype plugin indent on

let mapleader=' '

set hidden
set nospell
set noerrorbells novisualbell
set relativenumber " jump line numbers
set encoding=utf-8 fileencoding=utf-8
set noswapfile nobackup nowritebackup
set incsearch nohlsearch
set ignorecase
set smartcase
set smartindent expandtab tabstop=2 shiftwidth=2
set nowrap linebreak
set formatoptions+=j " Delete comment character when joining commented lines
set backspace=indent,eol,start " Allow backspace to delete indentation and inserted text
set undofile undodir=~/.vim/undodir " Maintain undo history between sessions
set clipboard^=unnamed,unnamedplus " Enable cross-app copy/paste after vim yank/paste
set noshowmode " Do not show mode on command line since vim-airline can show it
set cmdheight=2 " More space for bottom messages
set updatetime=50
set shortmess+=c " Don't pass messages to ins-completion-menu

" Command-line completion in enhanced mode
set wildmenu
set wildmode=list:longest,full

" trim trailing whitespace pre-save
autocmd BufWritePre * %s/\s\+$//e

" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" Disable ALE LSP in favor of CoC
let g:ale_disable_lsp = 1

" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Color Scheme
Plug 'morhetz/gruvbox'

" QoL
Plug 'preservim/nerdcommenter'
Plug 'vim-airline/vim-airline'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() }}
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'sheerun/vim-polyglot'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
autocmd FileType json syntax match Comment +\/\/.\+$+

" Lint / Fix
Plug 'dense-analysis/ale'

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

" FZF
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
let $FZF_DEFAULT_OPTS='--reverse'

" ALE
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'

let g:ale_lint_on_enter = 0
let g:ale_lint_on_save = 1
let g:ale_fix_on_enter = 1

let g:ale_linters = {
  \ 'javascript': ['eslint'],
  \ 'python': ['pylint'],
\}

let g:ale_fixers = {
  \ 'python': ['black'],
\}

" Remaps

" Search for word under cursor with RipGrep
nnoremap <leader>g :<C-U>execute "Rg ".expand('<cword>') \| cw<CR>
nnoremap <leader>ps :Rg<SPACE>

" Quick access to vimrc
nnoremap <leader>ev :vsplit $HOME/.vimrc<cr>
nnoremap <leader>sv :source $HOME/.vimrc<cr>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>+ :vertical resize +5<CR>
nnoremap <leader>- :vertical resize -5<CR>
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>

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

" FileBrowser w/ Netrw
let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_winsize = 75 " with 25 for netrw split
let g:netrw_list_hide=netrw_gitignore#Hide()

" Ripgrep
if executable('rg')
  let g:rg_derive_root='true'
endif

" NerdCommenter
let g:NERDSpaceDelims=1
let g:NERDTrimTrailingWhitespace=1

" Go
augroup filetype_go
  autocmd!
  autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

  " shortcut go error
  nnoremap <Leader>ee oif err != nil {<CR>log.Fatalf("%+v\n", err)<CR>}<CR><esc>kkI<esc>

  " Debug shortcuts
  nnoremap <leader>bp :GoDebugBreakpoint<CR>
  nnoremap <leader>dn :GoDebugContinue<CR>

  " we leave this hanging for flag input
  nnoremap <leader>dbs :GoDebugStart
  nnoremap <leader>dbe :GoDebugStop<CR>
augroup END

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

" Python
augroup filetype_python
  autocmd!
  autocmd FileType python set expandtab autoindent
  autocmd FileType python set tabstop=4 softtabstop=4 shiftwidth=4
augroup END

"CoC config
set signcolumn=yes

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Tab to trigger completion
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Or <C-space>
inoremap <silent><expr> <C-space> coc#refresh()

nnoremap <leader>cr :CocRestart<CR>
nnoremap <leader>ds :CocList diagnostics<CR>

" autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

nmap <leader>gd <Plug>(coc-definition)
nmap <leader>gi <Plug>(coc-implementation)
nmap <leader>gr <Plug>(coc-references)
nmap <leader>rr <Plug>(coc-rename)

" Full project word search (and replace if edited)
nmap <leader>prw :CocSearch <C-R>=expand("<cword>")<CR><CR>
