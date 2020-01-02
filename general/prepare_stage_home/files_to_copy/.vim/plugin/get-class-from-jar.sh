 #!/bin/bash

 pathToDecompiler="$HOME/bin/jad/jad -p -lnc -ff -space -t"

 fileType=$(echo $* | cut -f1 -d:)
 jarFile=$(echo $* | cut -f2 -d:)
 classFile=$(echo $* | cut -f4 -d:)
 uuid=$(uuidgen)
 
 
if [ "$fileType" = "zipfile" ]
then
     tmpDir=/tmp/$uuid
     unzip -qq $jarFile "`dirname $classFile`*" -d $tmpDir
     $pathToDecompiler $tmpDir/$classFile
     rm -rf $tmpDir >&/dev/null
else
     $pathToDecompiler $*
fi

