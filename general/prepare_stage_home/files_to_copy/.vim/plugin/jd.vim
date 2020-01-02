" 
" Based on - http://www.mej.xyz/notes/Java-decompile
"

au BufNewFile,BufRead,BufEnter *.class call SetClassOptions()
function SetClassOptions()
     silent %!~/.vim/plugin/get-class-from-jar.sh %
     set readonly
     set ft=java
     set syntax=java
     "silent normal gg=G
     set nomodified
     set nobin
endfunction

