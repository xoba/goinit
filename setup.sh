#!/bin/bash
mkdir -p go
mkdir -p go/src
echo ".git" >> go/.gitignore
echo "pkg" >> go/.gitignore
echo "bin" >> go/.gitignore
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
chmod u+x *.sh

