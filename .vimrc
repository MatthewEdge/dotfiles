set nocompatible
syntax on
filetype plugin indent on

let mapleader=' '

set noerrorbells novisualbell
set number " line numbers
set encoding=utf-8
set fileencoding=utf-8
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
set backspace=indent,eol,start " Allow backspace to delete indentation and inserted text

" trim trailing whitespace pre-save
autocmd BufWritePre * %s/\s\+$//e

" Enable cross-app copy/paste after vim yank/paste
set clipboard+=unnamedplus

" Do not show mode on command line since vim-airline can show it
set noshowmode

" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END


" Maintain undo history between sessions
set undofile
set undodir=~/.vim/undodir

" statusline
let g:currentmode={
       \ 'n'  : 'NORMAL ',
       \ 'v'  : 'VISUAL ',
       \ 'V'  : 'V·Line ',
       \ ''   : 'V·Block ',
       \ 'i'  : 'INSERT ',
       \ 'R'  : 'R ',
       \ 'Rv' : 'V·Replace ',
       \ 'c'  : 'Command ',
       \}

set statusline=
set statusline+=%1*

" Show current mode
set statusline+=\ %{toupper(g:currentmode[mode()])}
set statusline+=%{&spell?'[SPELL]':''}

set statusline+=%#Warnings#
set statusline+=%{&paste?'[PASTE]':''}

set statusline+=%2*
" File path, as typed or relative to current directory
set statusline+=\ %F

set statusline+=%{&modified?'\ [+]':''}
set statusline+=%{&readonly?'\ []':''}

" Truncate line here
set statusline+=%<

" Separation point between left and right aligned items.
set statusline+=%=

set statusline+=%{&filetype!=#''?&filetype.'\ ':'none\ '}

" Encoding & Fileformat
set statusline+=%#Warnings#
set statusline+=%{&fileencoding!='utf-8'?'['.&fileencoding.']':''}

set statusline+=%2*
set statusline+=%-7([%{&fileformat}]%)

" Warning about byte order
set statusline+=%#Warnings#
set statusline+=%{&bomb?'[BOM]':''}

set statusline+=%1*
" Location of cursor line
set statusline+=[%l/%L]

" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" QoL
Plug 'preservim/nerdcommenter'
" Plug 'vim-airline/vim-airline'

" Plug 'tpope/vim-fugitive'
Plug 'morhetz/gruvbox'
Plug 'ap/vim-css-color'

Plug 'christoomey/vim-tmux-navigator'

Plug 'sheerun/vim-polyglot'

" Go
Plug 'fatih/vim-go', {'do': ':GoUpdateBinaries', 'for': ['go']}
let g:go_def_mapping_enabled = 0 " Let coc manage nav

" Scala
Plug 'derekwyatt/vim-scala'
au BufRead,BufNewFile *.sbt set filetype=scala

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
autocmd FileType json syntax match Comment +\/\/.\+$+

call plug#end()

" Fix for languages that don't seem to work with polyglot
" let g:polyglot_disabled = ['scala', 'go']

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
" nnoremap <Leader>h :wincmd h<CR>
" nnoremap <Leader>j :wincmd j<CR>
" nnoremap <Leader>k :wincmd k<CR>
" nnoremap <Leader>l :wincmd l<CR>
" nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>
" nnoremap <silent> <leader>+ :vertical resize +5<CR>
" nnoremap <silent> <leader>- :vertical resize -5<CR>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" NerdCommenter
let g:NERDSpaceDelims=1
let g:NERDTrimTrailingWhitespace=1

" Go
autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

"CoC config
set hidden
set updatetime=300
set shortmess+=c
set signcolumn=yes

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

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
  " autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Format and organize imports
command! -nargs=0 Format :call CocAction('format')
nnoremap <Leader>f :Format<CR>
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
nnoremap <Leader>i :OR<CR>

" Prettier integration
command! -nargs=0 Prettier :CocCommand prettier.formatFile
