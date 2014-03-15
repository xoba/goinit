#!/bin/bash

# meant to be run as root

cd ~/

aptitude update && aptitude install -y gcc libc6-dev mercurial libtool emacs git

export GOROOT=~/go
export GOPATH=`mktemp -d`
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

time hg clone https://code.google.com/p/go

cat >> go/.hg/hgrc <<EOF
[extensions]
codereview = ~/go/lib/codereview/codereview.py
[ui]
username = Mike Andrews <mra@xoba.com>
EOF

cd ~/go/src
time ./make.bash
go get code.google.com/p/go.codereview/cmd/hgapplydiff

hg clpatch 34580043 # SO_REUSEPORT

cd ~/go/src
time ./all.bash

go get code.google.com/p/go.talks/present
#go get code.google.com/p/go.tools/cmd/...
go get code.google.com/p/go.tools/cmd/cover
go get code.google.com/p/go.tools/cmd/godoc
go get code.google.com/p/go.tools/cmd/goimports
go get code.google.com/p/go.tools/cmd/gotype
go get code.google.com/p/go.tools/cmd/oracle
go get code.google.com/p/go.tools/cmd/ssadump
go get code.google.com/p/go.tools/cmd/vet
go get github.com/dougm/goflymake
go get code.google.com/p/rog-go/exp/cmd/godef
go get code.google.com/p/go.codereview/cmd/hgapplydiff

cp $GOPATH/src/github.com/dougm/goflymake/*.el $GOROOT/misc/emacs/
cp $GOPATH/bin/* $GOROOT/bin/
mkdir $GOROOT/misc/present
mv $GOPATH/src/code.google.com $GOROOT/src/pkg

cat > $GOROOT/misc/emacs/.emacs <<EOF
(add-to-list 'load-path "~/go/misc/emacs/" t)
(require 'go-mode-load)
(add-hook 'before-save-hook #'gofmt-before-save)
(require 'go-flymake)
EOF

cp $GOROOT/misc/emacs/.emacs ~/

cd ~/
tar cf go.tar go
gzip go.tar
