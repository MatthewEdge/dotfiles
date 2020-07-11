set nocompatible
syntax on
filetype plugin indent on

let mapleader=' '

set hidden
set spell spelllang=en_us
set noerrorbells novisualbell
set relativenumber " jump line numbers
set encoding=utf-8 fileencoding=utf-8
set noswapfile nobackup nowritebackup
set incsearch ignorecase smartcase hlsearch
set smartindent expandtab tabstop=2 shiftwidth=2
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
Plug 'sheerun/vim-polyglot'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
autocmd FileType json syntax match Comment +\/\/.\+$+

" Go
Plug 'fatih/vim-go', {'do': ':GoUpdateBinaries'}

" Scala
Plug 'derekwyatt/vim-scala'
au BufRead,BufNewFile *.sbt set filetype=scala

call plug#end()

" Colorscheme
let g:gruvbox_contrast_dark = 'hard'
if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
let g:gruvbox_invert_selection='0'
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
nnoremap <leader>ps :Rg<SPACE>
nnoremap <leader>pf :Files<CR>
nnoremap <C-p> :GFiles<CR>
nnoremap <leader>+ :vertical resize +5<CR>
nnoremap <leader>- :vertical resize -5<CR>
" Move highlighted blocks up/down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" vim-fugitive
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
autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

" shortcut go error
nnoremap <Leader>ee oif err != nil {<CR>log.Fatalf("%+v\n", err)<CR>}<CR><esc>kkI<esc>

let g:go_def_mapping_enabled = 0 " Let coc manage nav
let g:go_auto_type_info = 1
let g:go_auto_sameids = 1
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

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

"CoC config
set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=yes

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Required for coc to function
inoremap <silent><expr> <TAB>
                \ pumvisible() ? "\<C-n>" :
                \ <SID>check_back_space() ? "\<TAB>" :
                \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <silent><expr> <C-space> coc#refresh()

" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" keys for gotos
nmap <leader>gd <Plug>(coc-definition)
nmap <leader>gi <Plug>(coc-implementation)
nmap <leader>gr <Plug>(coc-references)
nmap <leader>rr <Plug>(coc-rename)
nmap <leader>prw :CocSearch <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>cr :CocRestart<CR>

" Format and organize imports
command! -nargs=0 Format :call CocAction('format')
nnoremap <leader>f :Format<CR>
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
nnoremap <leader>oi :OR<CR>
