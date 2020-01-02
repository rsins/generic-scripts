set nocompatible              " be iMproved, required
filetype off                  " required

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
"set background=dark
set cursorline
hi CursorLine term=bold cterm=NONE ctermbg=234
set hlsearch
nnoremap <C-l> :nohl<CR><C-L>
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
let &t_SI = "\<Esc>]50;CursorShape=1\x7\<Esc>\\"
"let &t_SR = "\<Esc>]50;CursorShape=2\x7\<Esc>\\"
let &t_EI = "\<Esc>]50;CursorShape=0\x7\<Esc>\\"

" Set the cursor shape while entering vim
au VimEnter * let &t_ti = "\<Esc>]50;CursorShape=0\x7\<Esc>\\"
" Return the cursor shape back while exiting Vim
au VimLeave * let &t_te = "\<Esc>]50;CursorShape=1\x7\<Esc>\\"

