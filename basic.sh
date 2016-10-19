#!/bin/bash -e
#
# basic go build with additional stuff
#
export GOROOT=~/go
export GOPATH=/tmp/gopaths/`uuidgen`
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH

mkdir -p $GOPATH
rm -rf $GOROOT/bin

cd $GOROOT/src
# ./make.bash

go get golang.org/x/tools/cmd/cover
go get golang.org/x/tools/cmd/godoc
go get golang.org/x/tools/cmd/stringer
go get golang.org/x/tools/cmd/goimports
go get golang.org/x/tools/cmd/gotype
go get golang.org/x/tools/cmd/gorename
go get golang.org/x/tools/cmd/callgraph
go get golang.org/x/tools/cmd/gomvpkg
go get golang.org/x/tools/cmd/guru
go get github.com/golang/lint/golint
go get github.com/dougm/goflymake
go get github.com/rogpeppe/godef

cp $GOPATH/bin/* $GOROOT/bin/

cd $GOROOT
rm -rf misc/emacs 
mkdir -p misc/emacs

cd $GOPATH
git clone https://github.com/dominikh/go-mode.el.git

find $GOPATH -type f -name "*.el" -exec cp \{} $GOROOT/misc/emacs/ \;

echo "GOPATH = $GOPATH"
