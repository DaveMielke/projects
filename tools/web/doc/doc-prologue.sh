#!/bin/sh
. "brltty-prologue.sh"

documentDirectory="/mnt/opt/dave/web/doc"
backupDirectory="/home/dave/gdrv/Documents/Pages"

addProgramParameter "document name" documentName "the name of the document"
parseProgramArguments "${@}"

for documentExtension in html php txt xml jpg png
do
   documentFile="${documentName}.${documentExtension}"
   documentPath="${documentDirectory}/${documentFile}"

   [ -e "${documentPath}" ] && {
      verifyInputFile "${documentPath}"
      return 0
   }
done

semanticError "document not found: ${documentName}"
