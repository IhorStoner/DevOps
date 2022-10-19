#!/usr/bin/env bash

#Create dir. First params - parent folder. Second param - dir name
function createDir() {
  ! [ -d "$1/$2" ] && cd "$1" && mkdir "$2"
}

#Create file. First param - parent folder. Second param - file name
function createFile() {
  ! [ -f "$1/$2" ] && cd "$1" && touch "$2"
}

#Return current root group dir
function checkRootGroup() {
    if [[  "$OSTYPE" == "darwin"* ]];
      then
        echo "admin"

      else
        echo "root"
    fi
}

#1. Create dir
mainDir="task"
createDir "$HOME" $mainDir

for group in $(groups) ; do
  createDir "$HOME/$mainDir" "$group" #2. Create group dirs

  rootGroup=$(checkRootGroup)
  chown "root:$rootGroup" "$HOME/$mainDir/$group" #3.1 Change owner
  chmod 607 "$HOME/$mainDir/$group" #3.2 Change permission

done

chmod g+s "$HOME/$mainDir" #4.1 SGID for mainDir
chmod +t "$HOME/$mainDir" #4.2 Sticky bit for mainDir


createFile "$HOME/$mainDir" "test.txt" #5. Create test file
! [ -f "$HOME/$mainDir/hardlink.txt" ] && cd "$HOME/$mainDir" && ln "test.txt" "hardlink.txt" #5.1 Create hardlink to test file
! [ -f "$HOME/$mainDir/softlink.txt" ] && cd "$HOME/$mainDir" && ln -s "test.txt" "softlink.txt" #5.2 Create softlink to test file

#6. Create 10 file and archive them
dirNameForFiles="files"
createDir "$HOME/$mainDir" "$dirNameForFiles"

for (( i = 0; i < 10; i++ )); do
    createFile "$HOME/$mainDir/$dirNameForFiles" "test_$i.txt"
done

cd "$HOME/$mainDir" && tar -cvf "archive.tar" "./$dirNameForFiles"
cd "$HOME/$mainDir" && gzip "archive.tar"
#files created ↑