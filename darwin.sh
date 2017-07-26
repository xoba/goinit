#!/bin/bash
cd ~/
export GOROOT=~/go
export GOPATH=/tmp/gopath
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
rm -rf go
curl -o go1.8.3.darwin-amd64.tar.gz https://storage.googleapis.com/golang/go1.8.3.darwin-amd64.tar.gz
tar xf go1.8.3.darwin-amd64.tar.gz
rm go1.8.3.darwin-amd64.tar.gz
mv go go1.8.3
cd go1.8.3
export GOROOT_BOOTSTRAP=`pwd`
cd ~/
git clone https://go.googlesource.com/go
cd go/src
time ./all.bash
go get golang.org/x/tools/cmd/cover
go get golang.org/x/tools/cmd/godoc
go get golang.org/x/tools/cmd/stringer
go get golang.org/x/tools/cmd/goimports
go get golang.org/x/tools/cmd/gorename
go get golang.org/x/tools/cmd/callgraph
go get golang.org/x/tools/cmd/gomvpkg
go get golang.org/x/tools/cmd/guru
go get github.com/golang/lint/golint
go get github.com/dougm/goflymake
go get github.com/rogpeppe/godef
go get github.com/mvdan/interfacer/cmd/interfacer

mkdir -p ../misc/emacs

cd $GOPATH
git clone https://github.com/dominikh/go-mode.el.git

find $GOPATH -type f -name "*.el" -exec cp \{} $GOROOT/misc/emacs/ \;

cp $GOPATH/bin/* $GOROOT/bin/

cat > $GOROOT/misc/emacs/.emacs <<EOF
(set-face-attribute 'default nil :height 110)
(set-cursor-color "white") 
(set-foreground-color "white")
(set-background-color "black")
(add-to-list 'default-frame-alist '(foreground-color . "white"))
(add-to-list 'default-frame-alist '(background-color . "black"))
(add-to-list 'load-path "~/go/misc/emacs")
(require 'go-mode-autoloads)
(setq gofmt-command "goimports")
(add-hook 'before-save-hook #'gofmt-before-save)
(require 'go-flymake)
(require 'go-rename)
(require 'go-guru)
(require 'golint)
EOF
