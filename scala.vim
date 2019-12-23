" Scala Settings
au BufRead,BufNewFile *.sbt set filetype=scala

" coc-metals for Scala
set updatetime=300
set shortmess+=c
set nobackup
set nowritebackup
set cmdheight=2

augroup scalabindings
  autocmd! scalabindings
  autocmd Filetype scala inoremap <silent><expr> <c-space> coc#refresh()
  autocmd Filetype scala inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
augroup end
