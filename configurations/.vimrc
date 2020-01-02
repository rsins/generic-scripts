set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Python autocompletion plugin
Plugin 'davidhalter/jedi-vim'
Plugin 'timakro/vim-searchant'

" Plugin for Bash autocompletion
Plugin 'WolfgangMehner/bash-support'

" Plugin for javascript syntax highliting and indentation
Plugin 'pangloss/vim-javascript'

" Plugin to use with netrc for directory listing
Plugin 'tpope/vim-vinegar'

" Plugin for vim tabs
"Plugin 'humiaozuzu/tabbar'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

syntax on
set ruler
set ic
set ai
set magic
set sm
set number
"set expandtab
set noet ci pi sts=0 sw=4 ts=4
set listchars=eol:$,tab:>.,trail:~,extends:>,precedes:<,nbsp:%
set cursorline
hi CursorLine term=bold cterm=NONE ctermbg=234
set hlsearch
set backspace=2

hi TabLineFill cterm=none ctermfg=white  ctermbg=234
hi TabLine     cterm=none ctermfg=white  ctermbg=234
hi TabLineSel  cterm=none ctermfg=black  ctermbg=white

" Some customizations
nnoremap <C-L> :nohl<CR><C-L>			" Redraw screen
nnoremap <tab> <C-W><C-W>				" Use TAB to go to next window
nnoremap <C-E> :e!<CR>					" Ctrl-E to reload file
nnoremap <C-Q> :q<CR>                   " Ctrl-E to exit
nnoremap <C-N> :tabnext<CR>             " Ctrl-N to next tab
nnoremap <C-P> :tabprev<CR>             " Ctrl-P to previous tab
" Ctrl-T to start editing a file in new tab
nnoremap <C-T> :tabedit 
 
" Enable Mouse Support
if has('mouse')
   set mouse=a
endif

" Return to last edit position when opening files
if has("autocmd")
   au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" netrw related customizations
let g:netrw_banner        = 1		" Show the netws banner
let g:netrw_liststyle     = 3		" Tree Style Listing
let g:netrw_browse_split  = 0		" Open in Same Window
let g:netrw_winsize       = 75		" % width to open new window in
let g:netrw_altv          = 0       " Open new window in left side of listing if 'v' key pressed

" For Different Cursor Shapes in Vim Editor. This works inside tmux.
"    - t_SI = Insert Mode
"    - t_SR = Replace Mode
"    - t_EI = Exit Insert Mode
"    - CursorShape
"        0 = bar
"        1 = vertical line
"        2 = underscore
let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
" Being handled by terminux plugin

