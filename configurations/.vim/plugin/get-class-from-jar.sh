#!/bin/bash

pathToDecompiler="java -jar $HOME/Bin/java_decompiler/fernflower.jar -din=1 -dgs=1"

fileType=$(echo $* | cut -f1 -d:)
jarFile=$(echo $* | cut -f2 -d:)
classFile=$(echo $* | cut -f4 -d:)
javaFile="$(basename $classFile .class).java"
uuid=$(uuidgen)
 
if [ "$fileType" = "zipfile" ]
then
     tmpDir=/tmp/$uuid
     unzip -qq "$jarFile" "`dirname $classFile`*" -d $tmpDir
     if [[ "$classFile" == *'$'* ]] # if file name is inner class
     then
         $pathToDecompiler "$tmpDir/$classFile" $tmpDir >&/dev/null
     else
         $pathToDecompiler "$tmpDir/`dirname $classFile`" $tmpDir >&/dev/null
     fi
     cat "$tmpDir/$javaFile"
     rm -rf $tmpDir >&/dev/null
else
     $pathToDecompiler $* /tmp  >&/dev/null
     cat "/tmp/$javaFile"
     rm -f "/tmp/$javaFile" >&/dev/null
fi

