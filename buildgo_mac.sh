#!/bin/bash -e

#
# installs go into home directory, also creates go.tar.gz
#

cd ~/

export GOROOT=~/go
export GOPATH=`mktemp -d /tmp/tmp.XXXXXXXXX`
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH

hg clone https://code.google.com/p/go

cd ~/go/src

./make.bash

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
export GOARCH=amd64
./make.bash --no-clean
rm -rf ~/go/bin/linux_amd64/

export GOOS=linux
export GOARCH=arm
./make.bash --no-clean
rm -rf ~/go/bin/linux_arm/

export GOOS=windows
export GOARCH=amd64
./make.bash --no-clean
rm -rf ~/go/bin/windows_amd64/

rm -rf $GOPATH

cd ~/
tar cf go.tar go
gzip -f go.tar