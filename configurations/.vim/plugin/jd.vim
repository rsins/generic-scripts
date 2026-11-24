" 
" Based on - http://www.mej.xyz/notes/Java-decompile
"

au BufNewFile,BufRead,BufEnter *.class call SetClassOptions()
function SetClassOptions()
     silent %!~/.vim/plugin/get-class-from-jar.sh '%'
     set readonly
     "silent normal gg=G
     set nomodified
     set nobin
     set ft=java
     set syntax=java

     "Defer the filetype execution until the buffer is stable
     call timer_start(1, {-> execute('set ft=java')})
endfunction

