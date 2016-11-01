#!/bin/bash
#
# build a customize version of latest stable production go
#
rm -rf go
git clone https://go.googlesource.com/go
cd go
git checkout go1.7.3
sed -i -e 's/*39/*41/g' src/runtime/malloc.go
sed -i -e 's/sys.TheVersion/sys.TheVersion+" (41 bits heap)"/g' src/runtime/extern.go
export GOROOT_BOOTSTRAP=$GOROOT
cd src
./make.bash
