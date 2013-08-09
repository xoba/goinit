#!/bin/bash
source config.txt

mkdir -p go
mkdir -p go/src
mkdir -p go/src/$BUILD

wget -N https://raw.github.com/xoba/goinit/master/uniq.sh
wget -N https://raw.github.com/xoba/goinit/master/aws-ide.sh
wget -N https://raw.github.com/xoba/goinit/master/genbuild.sh
wget -N https://raw.github.com/xoba/goinit/master/gofiles.sh
wget -N https://raw.github.com/xoba/goinit/master/goinit.sh
wget -N https://raw.github.com/xoba/goinit/master/ide.sh
wget -N https://raw.github.com/xoba/goinit/master/install.sh
wget -N https://raw.github.com/xoba/goinit/master/pull.sh
wget -N https://raw.github.com/xoba/goinit/master/push.sh
wget -N https://raw.github.com/xoba/goinit/master/sourcefiles.sh
wget -N https://raw.github.com/xoba/goinit/master/x-ide.sh
wget -N https://raw.github.com/xoba/goinit/master/clean.sh
wget -N https://raw.github.com/xoba/goinit/master/format.sh
wget -N https://raw.github.com/xoba/goinit/master/replace.sh
chmod u+x *.sh

echo ".git" >> go/.gitignore
echo "pkg" >> go/.gitignore
echo "bin" >> go/.gitignore
./uniq.sh go/.gitignore

echo "build.go" >> go/src/$BUILD/.gitignore
./uniq.sh go/src/$BUILD/.gitignore

rm uniq.sh
