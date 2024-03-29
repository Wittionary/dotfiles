" First things first: https://raw.githubusercontent.com/tomasiser/vim-code-dark/master/colors/codedark.vim
colorscheme codedark

" numbers on left-hand side
set number
" relative numbers on left-hand side
set relativenumber
" Highlight cursor line underneath the cursor horizontally.
set cursorline
" Highlight cursor line underneath the cursor vertically.
set cursorcolumn

" Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=10

" Enable type file detection
filetype on
" Turn syntax highlighting on
syntax on

" MAPPINGS ---------------------------
inoremap jj <Esc>

" Shift+Tab functionality for command mode and insert mode
nnoremap <S-Tab> <<
inoremap <S-Tab> <C-d>
