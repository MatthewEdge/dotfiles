set nocompatible
syntax on
filetype plugin indent on

let mapleader=' '

set noerrorbells
set number " line numbers
set encoding=utf-8
set fileencoding=utf-8
set ttyfast
set noswapfile
set nobackup
set incsearch
set autoindent
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set wrap
set linebreak
set formatoptions+=j " Delete comment character when joining commented lines
autocmd BufWritePre * %s/\s\+$//e " trim trailing whitespace pre-save
set backspace=indent,eol,start " Allow backspace to delete indentation and inserted text

" Maintain undo history between sessions
set undofile
set undodir=~/.vim/undodir

" Find Files - search subfolders and provide tab completion
" set path+=**

" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" QoL
Plug 'preservim/nerdcommenter'
" Plug 'tpope/vim-surround'
" Plug 'tpope/vim-fugitive'
Plug 'morhetz/gruvbox'
Plug 'ap/vim-css-color'
" Plug 'git@github.com:kien/ctrlp.vim.git'

Plug 'christoomey/vim-tmux-navigator'

Plug 'sheerun/vim-polyglot'

" Go
Plug 'fatih/vim-go', {'do': ':GoUpdateBinaries', 'for': ['go']}
let g:go_def_mapping_enabled = 0 " Let coc manage nav

" Scala
Plug 'derekwyatt/vim-scala'

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
autocmd FileType json syntax match Comment +\/\/.\+$+

call plug#end()

" Fix for languages that don't seem to work with polyglot
let g:polyglot_disabled = ['scala', 'go']

" tmux
nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
nnoremap <silent> <c-/> :TmuxNavigatePrevious<cr>

" Colorscheme
let &t_Co=256
colorscheme gruvbox
set background=dark

" FileBrowser w/ Netrw
let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_winsize = 75 " with 25 for netrw split
let g:netrw_list_hide=netrw_gitignore#Hide()

" Vim splits
nnoremap <Leader>h :wincmd h<CR>
nnoremap <Leader>j :wincmd j<CR>
nnoremap <Leader>k :wincmd k<CR>
nnoremap <Leader>l :wincmd l<CR>
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>
nnoremap <silent> <leader>+ :vertical resize +5<CR>
nnoremap <silent> <leader>- :vertical resize -5<CR>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" NerdCommenter
let g:NERDSpaceDelims=1
let g:NERDTrimTrailingWhitespace=1

" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" make/cmake
augroup vimrc-make-cmake
  autocmd!
  autocmd FileType make setlocal noexpandtab
  autocmd BufNewFile,BufRead CMakeLists.txt setlocal filetype=cmake
augroup END

" Scala
au BufRead,BufNewFile *.sbt set filetype=scala

" Go
autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

"CoC config
set updatetime=300
set shortmess+=c
" set cmdheight=2
set signcolumn=yes
set statusline=""

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Use K to either doHover or show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>

augroup cocformatter
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType scala setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Fix autofix problem of current line
nmap <leader>qf <Plug>(coc-fix-current)

" Format and organize imports
command! -nargs=0 Format :call CocAction('format')
nnoremap <Leader>f :Format<CR>
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
nnoremap <Leader>i :OR<CR>

" Prettier integration
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" Fix common mistypings
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qal

