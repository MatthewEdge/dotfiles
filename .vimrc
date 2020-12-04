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
set incsearch nohlsearch
" set ignorecase
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
Plug 'stsewd/fzf-checkout.vim'
Plug 'tpope/vim-fugitive'
Plug 'morhetz/gruvbox'
Plug 'sheerun/vim-polyglot'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
autocmd FileType json syntax match Comment +\/\/.\+$+

" Go
Plug 'fatih/vim-go', {'do': ':GoUpdateBinaries'}

call plug#end()

" FZF
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
let $FZF_DEFAULT_OPTS='--reverse'

" Colorscheme
colorscheme gruvbox
set background=dark
let g:gruvbox_contrast_dark = 'hard'
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
let g:gruvbox_invert_selection='0'

" Remaps
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>
nnoremap <leader>ps :Rg<SPACE>
nnoremap <leader>pf :Files<CR>
nnoremap <leader>ds :CocList diagnostics<CR>
nnoremap <C-p> :GFiles<CR>
nnoremap <leader>+ :vertical resize +5<CR>
nnoremap <leader>- :vertical resize -5<CR>
" Move highlighted blocks up/down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Open in Firefox
nnoremap <leader>of :!open -a Firefox %<CR><CR>

" vim-fugitive
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
autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

" shortcut go error
nnoremap <Leader>ee oif err != nil {<CR>log.Fatalf("%+v\n", err)<CR>}<CR><esc>kkI<esc>

let g:go_def_mapping_enabled = 0
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

" autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

nmap <leader>gd <Plug>(coc-definition)
nmap <leader>gi <Plug>(coc-implementation)
nmap <leader>gr <Plug>(coc-references)
nmap <leader>rr <Plug>(coc-rename)

" Full project word search (and replace if edited)
nmap <leader>prw :CocSearch <C-R>=expand("<cword>")<CR><CR>

" Format and organize imports
command! -nargs=0 Format :call CocAction('format')
nnoremap <leader>f :Format<CR>
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
nnoremap <leader>oi :OR<CR>
