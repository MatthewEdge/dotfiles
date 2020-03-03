set nocompatible
syntax enable
filetype plugin indent on
set number
set encoding=utf-8
set fileencoding=utf-8

" Vim splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Indentation
set autoindent
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set formatoptions+=j " Delete comment character when joining commented lines

" Allow backspace to delete indentation and inserted text
set backspace=indent,eol,start

set incsearch
set ruler
set history=1000

" Maintain undo history between sessions
set undofile
set undodir=~/.vim/undodir

" Find Files - search subfolders and provide tab completion
set path+=**

" Display all matching files for tab complete in :find
set wildmenu

" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" QoL
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'jaredgorski/spacecamp'
Plug 'preservim/nerdcommenter'

" tmux and Vim
" Plug 'benmills/vimux'
Plug 'christoomey/vim-tmux-navigator'

" LSP Integration for languages that support it
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'

" Scala
Plug 'derekwyatt/vim-scala', {'for': ['scala']}
" Plug 'scalameta/coc-metals', {'do': 'yarn install --frozen-lockfile', 'for': ['scala']}
au BufRead,BufNewFile *.sbt set filetype=scala

" Java
Plug 'artur-shaik/vim-javacomplete2'

" JS/JSX
Plug 'MaxMEllon/vim-jsx-pretty'

call plug#end()

" Colorscheme
let &t_Co=256
colorscheme spacecamp_lite

" FileBrowser w/ Netrw
let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\|\s\s\)\zs\.\S\+' " ??
let g:netrw_localrmdir='rm -r'
let g:netrw_winsize = 75

" NerdCommenter
let g:NERDSpaceDelims=1
let g:NERDTrimTrailingWhitespace=1

" vim-tmux-nav
let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
nnoremap <silent> <c-/> :TmuxNavigatePrevious<cr>

command! -nargs=0 Prettier :CocCommand prettier.formatFile
