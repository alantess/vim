" Plugins will be downloaded under the specified directory.
call plug#begin('~/.config/nvim/plugged')
Plug 'puremourning/vimspector'
Plug 'peterhoeg/vim-qml'
Plug 'hhatto/autopep8'
Plug 'tpope/vim-commentary'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'ervandew/supertab'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-sensible'
Plug 'junegunn/seoul256.vim'
Plug 'vim-syntastic/syntastic'
Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-tmux-navigator'
Plug 'ambv/black'
Plug 'kien/ctrlp.vim'
Plug 'morhetz/gruvbox'
Plug 'jiangmiao/auto-pairs'
Plug 'rhysd/vim-clang-format'
" List ends here. Plugins become visible to Vim after this call.
call plug#end()

filetype plugin on 
let g:AutoPairsFlyMode = 0
let g:AutoPairsShortcutBackInsert = '<M-b>'



let g:python3_host_prog='/home/alan/miniconda3/envs/ai/bin/python3'


let g:clang_format#style_options = {
            \ "AccessModifierOffset" : -4,
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "Standard" : "C++11"}

" map to <Leader>cf in C++ code
autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
" if you install vim-operator-user
autocmd FileType c,cpp,objc map <buffer><Leader>x <Plug>(operator-clang-format)
" Toggle auto formatting:
let mapleader = "f"
nmap <Leader>i :ClangFormatAutoToggle<CR>
" for normal mode - the word under the cursor
nmap <Leader>di <Plug>VimspectorBalloonEval
" for visual mode, the visually selected text
xmap <Leader>di <Plug>VimspectorBalloonEval



syntax on
set tabstop=2 softtabstop=2
set shiftwidth=2
set expandtab
set copyindent
set nu rnu
set noswapfile
set autoindent
set smartindent
set incsearch
set ruler
set hlsearch
set showmatch


highlight Comment ctermfg=10
colorscheme slate



