#!/bin/bash

server=$1

#first param - server(parallels@10.211.55.10)
#second param - directory for copy
#third param - path to insert
copyFilesToServer() {
  server=$1
  dirForCopy=$2
  pathToInsert=$3

  cd "$dirForCopy"
  files=$(find . -type f | wc -l)

  if [ "$files" -gt 3 ]; then
      scp -r "$dirForCopy" "$server:$pathToInsert" && echo "copy files success"
  fi
}

pathToInsert="~/Downloads"
copyFilesToServer "$server" "$(pwd)" "$pathToInsert" #call function copyFiles

dirName="${PWD##*/}"
ssh "$server" ls -l "$pathToInsert/$dirName" #list copied files
ssh "$server" "find "$pathToInsert -type d -name $dirName" | xargs rm -d -r" #remove dir


fileNames=(test_1.txt test_2.txt) #files array
for file in ${fileNames[@]}; do
  ssh "$server" "cd $pathToInsert && touch $file" #create file
  scp "$server:$pathToInsert/$file" "$dirForCopy" #copy from vm
done



