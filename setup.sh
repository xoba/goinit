#!/bin/bash
#
# builds and installs a nice go language environment for emacs etc.
#

export TMP=`mktemp -d`
echo "working in: $TMP"
cd $TMP

if [[ `uname` == 'Linux' ]]; then
  export TAR="go1.11.1.linux-amd64.tar.gz"
else
  export TAR="go1.11.1.darwin-amd64.tar.gz"
fi

#curl https://dl.google.com/go/$TAR -o go.tar.gz
cp ~/goinit/go.tar.gz .

tar xf go.tar.gz
rm go.tar.gz
export GOROOT=$TMP/go
mkdir gopath
export GOPATH=$TMP/gopath
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
go version

go get -v golang.org/x/tools/cmd/cover
go get -v golang.org/x/tools/cmd/godoc
go get -v golang.org/x/tools/cmd/stringer
go get -v golang.org/x/tools/cmd/goimports
go get -v golang.org/x/tools/cmd/gorename
go get -v golang.org/x/tools/cmd/callgraph
go get -v golang.org/x/tools/cmd/gomvpkg
go get -v golang.org/x/tools/cmd/guru
go get -v github.com/golang/lint/golint
go get -v github.com/dougm/goflymake
go get -v github.com/rogpeppe/godef
go get -uv mvdan.cc/interfacer

cd $GOPATH

git clone https://github.com/dominikh/go-mode.el.git
cd go-mode.el
git checkout 99b06da

mv $GOPATH/go-mode.el $GOROOT/misc/emacs

cp $GOPATH/bin/* $GOROOT/bin/

cat > $GOROOT/misc/emacs/.emacs <<EOF
(setq ring-bell-function 'ignore)
(set-face-attribute 'default nil :height 170)
(set-cursor-color "white") 
(set-foreground-color "white")
(set-background-color "black")
(add-to-list 'default-frame-alist '(foreground-color . "white"))
(add-to-list 'default-frame-alist '(background-color . "black"))
(add-to-list 'load-path "~/go/misc/emacs")
(require 'go-mode-autoloads)
(setq gofmt-command "goimports")
(add-hook 'before-save-hook #'gofmt-before-save)
(require 'go-rename)
(require 'go-guru)
(require 'go-flymake)
(require 'golint)
EOF

echo "copy and paste the following into terminal to install:"
echo "mv ~/go `mktemp -d`"
echo "mv $TMP/go ~/go"
