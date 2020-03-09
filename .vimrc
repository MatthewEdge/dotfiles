set nocompatible
syntax enable
filetype plugin indent on
set splitbelow
set number
set encoding=utf-8
set fileencoding=utf-8
set ttyfast
set autochdir
set fileformats=unix
set incsearch
set ruler

let mapleader=','

" Indentation
set autoindent
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set formatoptions+=j " Delete comment character when joining commented lines
autocmd BufWritePre * %s/\s\+$//e " trim trailing whitespace pre-save

" Allow backspace to delete indentation and inserted text
set backspace=indent,eol,start

" Maintain undo history between sessions
set history=1000
set undofile
set undodir=~/.vim/undodir

" Find Files - search subfolders and provide tab completion
set path+=**

" Display all matching files for tab complete in :find
set wildmenu

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

" terminal emulation
nnoremap <silent> <Leader>sh :terminal<CR>
set termwinsize=10x0

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

" LSP Integration for languages that support it
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'

" Go
Plug 'fatih/vim-go', {'do': ':GoInstallBinaries'}

" Scala
Plug 'derekwyatt/vim-scala', {'for': ['scala']}
" Plug 'scalameta/coc-metals', {'do': 'yarn install --frozen-lockfile', 'for': ['scala']}
au BufRead,BufNewFile *.sbt set filetype=scala

" Java
Plug 'artur-shaik/vim-javacomplete2', {'for': ['java']}

" JS/JSX
Plug 'jelera/vim-javascript-syntax', {'for': ['js']}
let g:javascript_enable_domhtmlcss = 1

Plug 'leafgarland/typescript-vim', {'for': ['ts']}
Plug 'HerringtonDarkholme/yats.vim', {'for': ['ts']}
Plug 'MaxMEllon/vim-jsx-pretty'

" vuejs
Plug 'posva/vim-vue', {'for': ['vue']}
Plug 'leafOfTree/vim-vue-plugin', {'for': ['vue']}
let g:vue_disable_pre_processors=1
let g:vim_vue_plugin_load_full_syntax = 1

" HTML/CSS
Plug 'hail2u/vim-css3-syntax', {'for': ['css']}
Plug 'ap/vim-css-color', {'for': ['css']}

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
let g:netrw_winsize = 75 " with 25 for netrw split
nnoremap <Leader>pt :Vex<CR>

" Vim splits
nmap <Leader>h :wincmd h<CR>
nmap <Leader>j :wincmd j<CR>
nmap <Leader>k :wincmd k<CR>
nmap <Leader>l :wincmd l<CR>
noremap <Leader>\ :<C-u>split<CR>
noremap <Leader>- :<C-u>vsplit<CR>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
map - <C-W>-
map + <C-W>+
vmap <Leader>= <C-W><C-=>

" NerdCommenter
let g:NERDSpaceDelims=1
let g:NERDTrimTrailingWhitespace=1

"" The PC is fast enough, do syntax highlight syncing from start unless 200 lines
" augroup vimrc-sync-fromstart
  " autocmd!
  " autocmd BufEnter * :syntax sync maxlines=200
" augroup END

"" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

"" make/cmake
augroup vimrc-make-cmake
  autocmd!
  autocmd FileType make setlocal noexpandtab
  autocmd BufNewFile,BufRead CMakeLists.txt setlocal filetype=cmake
augroup END

" vim-go
" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

let g:go_list_type = "quickfix"
let g:go_fmt_command = "goimports"
" let g:go_fmt_fail_silently = 1
" let g:go_highlight_types = 1
" let g:go_highlight_fields = 1
" let g:go_highlight_functions = 1
" let g:go_highlight_methods = 1
" let g:go_highlight_operators = 1
" let g:go_highlight_build_constraints = 1
" let g:go_highlight_structs = 1
" let g:go_highlight_generate_tags = 1
" let g:go_highlight_space_tab_error = 0
" let g:go_highlight_array_whitespace_error = 0
" let g:go_highlight_trailing_whitespace_error = 0
" let g:go_highlight_extra_types = 1

autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

" coc config
set updatetime=300
set shortmess+=c
set nobackup
set nowritebackup
set cmdheight=2

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
" inoremap <silent><expr> <TAB>
      " \ pumvisible() ? "\<C-n>" :
      " \ <SID>check_back_space() ? "\<TAB>" :
      " \ coc#refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" function! s:check_back_space() abort
  " let col = col('.') - 1
  " return !col || getline('.')[col - 1]  =~# '\s'
" endfunction

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

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

" Fix autofix problem of current line
nmap <leader>qf <Plug>(coc-fix-current)

" Format and organize imports
command! -nargs=0 Format :call CocAction('format')
nnoremap <Leader>f :Format<CR>
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
nnoremap <Leader>i :OR<CR>

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>

" Prettier integration
command! -nargs=0 Prettier :CocCommand prettier.formatFile
