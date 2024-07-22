" Specify a directory for plugins
call plug#begin('~/.config/nvim/plugged')

" Plugins
Plug 'morhetz/gruvbox'                  " Gruvbox theme
Plug 'preservim/nerdtree'               " File explorer
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Syntax highlighting
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Code completion and linting

" Initialize plugin system
call plug#end()

" Theme settings
syntax enable
set background=dark
colorscheme gruvbox

" General settings
set number                           " Show line numbers
set relativenumber                   " Show relative line numbers
set tabstop=4                        " Number of spaces tabs count for
set shiftwidth=4                     " Number of spaces to use for (auto)indent step
set expandtab                        " Use spaces instead of tabs
set smartindent                      " Auto indent new lines
set autoindent                       " Keep indent of the previous line
set clipboard=unnamedplus            " Use system clipboard
set mouse=a                          " Enable mouse support

" Python specific settings
autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab

" C specific settings
autocmd FileType c,cpp setlocal tabstop=4 shiftwidth=4 expandtab

" Bash specific settings
autocmd FileType sh setlocal tabstop=4 shiftwidth=4 expandtab

" NERDTree settings
map <C-n> :NERDTreeToggle<CR>
autocmd vimenter * if !argc() | NERDTree | endif

" CoC (Conquer of Completion) settings
" Use tab for trigger completion with characters ahead and navigate
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin
inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)