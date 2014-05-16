#!/bin/bash -e

#
# installs go into home directory, also creates go.tar.gz
#

cd ~/

sudo aptitude update && sudo aptitude install -y gcc libc6-dev mercurial git libtool make pkg-config

export GOROOT=~/go
export GOPATH=`mktemp -d`
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
# export GO_DISTFLAGS="-s"

hg clone https://code.google.com/p/go

cd ~/go/src

./all.bash

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
(add-to-list 'auto-mode-alist '("\\.nex\\'" . c-mode))
(set-cursor-color "white") 
(set-foreground-color "white")
(set-background-color "black")
(add-to-list 'default-frame-alist '(foreground-color . "white"))
(add-to-list 'default-frame-alist '(background-color . "black"))
(setq gofmt-command "goimports")
(add-to-list 'load-path "~/go/misc/emacs/" t)
(require 'go-mode-load)
(add-hook 'before-save-hook #'gofmt-before-save)
(require 'go-flymake)
(require 'golint)
EOF

export GOOS=linux
export GOARCH=arm
./make.bash --no-clean
rm -rf ~/go/bin/linux_arm/

export GOOS=darwin
export GOARCH=amd64
./make.bash --no-clean
rm -rf ~/go/bin/darwin_amd64/

export GOOS=windows
export GOARCH=amd64
./make.bash --no-clean
rm -rf ~/go/bin/windows_amd64/

unset GOOS
unset GOARCH
unset GOROOT
unset GOPATH

rm -rf $GOPATH

cd ~/
tar cf go.tar go
gzip -f go.tar
