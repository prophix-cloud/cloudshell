syntax on
" use spaces instead of tabs
set expandtab
set tabstop=4
set shiftwidth=4

" always show line numbers
set number

" highlight current line and column
set cursorline
set cursorcolumn

" Smart case searching
set ignorecase
set smartcase

" when doing :vs split right
set splitright
" when doing :sp split below
set splitbelow

" Enable the mouse in all modes
set mouse=a

" soft wrap
set textwidth=0
set wrapmargin=0
set wrap
set linebreak

""""""""""""""""""""""""""""""""""""""""
" Key Mappings
""""""""""""""""""""""""""""""""""""""""
" change the leader key to comma
let mapleader=","

" clear search highlighting with <space>,
map <space> :noh<CR>

" Quickly save, quit, or save-and-quit
map <leader>w :w<CR>
map <leader>x :x<CR>
map <leader>q :q<CR>

"navigate tabs
map <leader>n :tabn<CR>
map <leader>p :tabp<CR>

" tab for cycling through options
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" escape by mashing j and k
inoremap jk <Esc>
inoremap jj <Esc>

" sensible long line navigation
nmap j gj
nmap k gk

" open up netrw
map - :Explore<CR>
" hide the netrw banner
let g:netrw_banner = 0

" don't auto-fold
set foldlevelstart=99

" Escape mappings for terminal mode
:tnoremap <Esc> <C-\><C-n>
:tnoremap jk <C-\><C-n>
:tnoremap jj <C-\><C-n>