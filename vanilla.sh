#!/bin/bash -e

#
# set up vanilla go release, with customizations
#

function tmp() {
    echo `mktemp -d /tmp/go_XXXXXXXXXXXX`
}

wget https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz
tar xf go1.4.2.linux-amd64.tar.gz

cd go

export GOROOT=`pwd`
export GOPATH=$(tmp)
export PATH=$PATH:$GOROOT/bin

go get code.google.com/p/go.tools/cmd/goimports
go get code.google.com/p/go.tools/cmd/gotype
go get code.google.com/p/go.tools/cmd/oracle
go get github.com/dougm/goflymake
go get code.google.com/p/rog-go/exp/cmd/godef
go get code.google.com/p/go.codereview/cmd/hgapplydiff
go get github.com/golang/lint/golint

mkdir -p misc/emacs/work
cd misc/emacs/work
git clone https://github.com/dominikh/go-mode.el.git
cd go-mode.el
emacs -batch --eval "(let ((generated-autoload-file \"$(pwd)/go-mode-load.el\")) (update-directory-autoloads \".\"))"
mv go-mode.el ../../
mv go-mode-load.el ../../
cd ../../
rm -rf work

# remove a file with syntax errors
rm -f $GOPATH/src/code.google.com/p/rog-go/exp/abc/audio/output.go

cp $GOPATH/src/github.com/dougm/goflymake/*.el $GOROOT/misc/emacs/
cp $GOPATH/src/github.com/golang/lint/misc/emacs/*.el $GOROOT/misc/emacs/
cp $GOPATH/bin/* $GOROOT/bin/

cat > $GOROOT/misc/emacs/.emacs <<EOF
(set-face-attribute 'default nil :height 110)
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

rm -rf $GOPATH

