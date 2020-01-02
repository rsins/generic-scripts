#!/bin/bash

pathToDecompiler="$HOME/bin/java_decompiler/jad/jad -p -lnc -ff -space -t"
#pathToDecompiler="java -jar $HOME/bin/java_decompiler/cfr/cfr-0.144.jar"

fileType=$(echo $* | cut -f1 -d:)
jarFile=$(echo $* | cut -f2 -d:)
classFile=$(echo $* | cut -f4 -d:)
uuid=$(uuidgen)
 
if [ "$fileType" = "zipfile" ]
then
     tmpDir=/tmp/$uuid
     unzip -qq "$jarFile" "`dirname $classFile`*" -d $tmpDir
     $pathToDecompiler $tmpDir/$classFile
     rm -rf $tmpDir >&/dev/null
else
     $pathToDecompiler $*
fi

