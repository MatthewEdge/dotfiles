set nocompatible
syntax on

let &t_Co=256
colorscheme spacecamp_lite
filetype plugin on

set encoding=utf-8
set fileencoding=utf-8

" Switching Buffers
noremap <leader>[ :bp<return>
noremap <leader>] :bn<return>

" Indentation
set autoindent
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Allow backspace to delete indentation and inserted text
" i.e. how it works in most programs
set backspace=indent,eol,start
" indent  allow backspacing over autoindent
" eol     allow backspacing over line breaks (join lines)
" start   allow backspacing over the start of insert; CTRL-W and CTRL-U stop once at the start of insert.

" Maintain undo history between sessions
set undofile
set undodir=~/.vim/undodir

" Find Files - search subfolders and provide tab completion
set path+=**

" Display all matching files for tab complete in :find
set wildmenu

" FileBrowser w/ Netrw
let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\|\s\s\)\zs\.\S\+' " ??
let g:netrw_localrmdir='rm -r'

" Markdown
augroup Markdown
  autocmd!
  autocmd FileType markdown set wrap linebreak
augroup END

" NerdCommenter
let g:NERDSpaceDelims=1
let g:NERDTrimTrailingWhitespace=1
