call plug#begin()
call plug#end()

" Switching Buffers
noremap <leader>[ :bp<return>
noremap <leader>] :bn<return>

set nocompatible
syntax enable
filetype plugin on
set backspace=indent,eol,start

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
