#!/bin/bash

#
# installs go into home directory, also creates go.tar.gz
#

cd ~/

sudo aptitude update && sudo aptitude install -y gcc libc6-dev mercurial libtool emacs git make

cat >> ~/.hgrc <<EOF
[web]
cacerts = /etc/ssl/certs/ca-certificates.crt
EOF

export GOROOT=~/go
export GOPATH=`mktemp -d`
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

time hg clone https://code.google.com/p/go

cat >> go/.hg/hgrc <<EOF
[extensions]
codereview = ~/go/lib/codereview/codereview.py
[ui]
username = Joe Schmo <joe@example.org>
EOF

cd ~/go/src

# make golang, first pass for hgapplydiff
time ./make.bash

go get code.google.com/p/go.codereview/cmd/hgapplydiff

hg clpatch 34580043 # SO_REUSEPORT

cd ~/go/src

# make golang, second pass for tests
time ./all.bash

go get code.google.com/p/go.tools/cmd/goimports
go get code.google.com/p/go.talks/present
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
go get github.com/golang/lint/golint

# remove a file with syntax errors
rm -f $GOPATH/src/code.google.com/p/rog-go/exp/abc/audio/output.go

cp $GOPATH/src/github.com/dougm/goflymake/*.el $GOROOT/misc/emacs/
cp $GOPATH/src/github.com/golang/lint/misc/emacs/*.el $GOROOT/misc/emacs/
cp $GOPATH/bin/* $GOROOT/bin/
mkdir $GOROOT/misc/present
mv $GOPATH/src/code.google.com $GOROOT/src/pkg

cat > $GOROOT/misc/emacs/.emacs <<EOF
(set-foreground-color "black")
(set-background-color "white")
(add-to-list 'default-frame-alist '(foreground-color . "black"))
(add-to-list 'default-frame-alist '(background-color . "white"))
(setq gofmt-command "goimports")
(add-to-list 'load-path "~/go/misc/emacs/" t)
(require 'go-mode-load)
(add-hook 'before-save-hook #'gofmt-before-save)
(require 'go-flymake)
(require 'golint)
EOF

rm -rf $GOPATH

cd ~/
tar cf go.tar go
gzip -f go.tar
