set nocompatible
syntax on
filetype plugin indent on

let mapleader=' '

set hidden
set spell spelllang=en_us
set noerrorbells novisualbell
set number " line numbers
set encoding=utf-8 fileencoding=utf-8
set noswapfile nobackup nowritebackup
set incsearch ignorecase smartcase hlsearch
set smartindent expandtab tabstop=2 softtabstop=2 shiftwidth=2
set nowrap linebreak
set formatoptions+=j " Delete comment character when joining commented lines
set backspace=indent,eol,start " Allow backspace to delete indentation and inserted text
set undofile undodir=~/.vim/undodir " Maintain undo history between sessions
set clipboard^=unnamed,unnamedplus " Enable cross-app copy/paste after vim yank/paste
set noshowmode " Do not show mode on command line since vim-airline can show it

" trim trailing whitespace pre-save
autocmd BufWritePre * %s/\s\+$//e

" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END


" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" QoL
Plug 'preservim/nerdcommenter'
Plug 'vim-airline/vim-airline'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() }}
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'morhetz/gruvbox'
Plug 'ap/vim-css-color'
Plug 'mbbill/undotree'

" Markdown preview
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
autocmd FileType json syntax match Comment +\/\/.\+$+

Plug 'sheerun/vim-polyglot'

" Go
Plug 'fatih/vim-go', {'do': ':GoUpdateBinaries', 'for': ['go']}
let g:go_def_mapping_enabled = 0 " Let coc manage nav

" Scala
Plug 'derekwyatt/vim-scala'
au BufRead,BufNewFile *.sbt set filetype=scala

call plug#end()

" tmux
" nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
" nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
" nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
" nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
" nnoremap <silent> <c-/> :TmuxNavigatePrevious<cr>

" Colorscheme
colorscheme gruvbox
set background=dark

" Remaps
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>u :UndotreeShow<CR>
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>
nnoremap <Leader>ps :Rg<SPACE>
nnoremap <C-p> :GFiles<CR> " GFiles for git?
nnoremap <Leader>pf :Files<CR>
nnoremap <Leader>+ :vertical resize +5<CR>
nnoremap <Leader>- :vertical resize -5<CR>

" Move highlighted blocks up/down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

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

" Go
autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

"CoC config
" set updatetime=300
set shortmess+=c
set signcolumn=yes

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

fun! GoCoc()
  " Required for coc to function
  inoremap <buffer> <silent><expr> <TAB>
                  \ pumvisible() ? "\<C-n>" :
                  \ <SID>check_back_space() ? "\<TAB>" :
                  \ coc#refresh()
  inoremap <buffer> <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
  inoremap <buffer> <silent><expr> <C-space> coc#refresh()

  " Fix autofix problem of current line
  nmap <buffer> <leader>qf  <Plug>(coc-fix-current)

  " keys for gotos
  nmap <buffer> <leader>gd <Plug>(coc-definition)
  nmap <buffer> <leader>gy <Plug>(coc-type-definition)
  nmap <buffer> <leader>gi <Plug>(coc-implementation)
  nmap <buffer> <leader>gr <Plug>(coc-references)
  nmap <buffer> <leader>rn <Plug>(coc-rename)
  nnoremap <buffer> <leader>cr :CocRestart

  " Format and organize imports
  command! -nargs=0 Format :call CocAction('format')
  nnoremap <Leader>f :Format<CR>
  command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
  nnoremap <Leader>oi :OR<CR>

  " Prettier integration
  command! -nargs=0 Prettier :CocCommand prettier.formatFile
endfun

" In case we want to try YCM for ts/java/go
autocmd FileType * :call GoCoc()
