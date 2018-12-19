#!/bin/bash -e
#
# builds and installs a nice go language environment for emacs etc.
#

export VERSION="go1.12beta1"

export TMP=`mktemp -d`
echo "working in: $TMP"

if [[ `uname` == 'Linux' ]]; then
    export TAR="$VERSION.linux-amd64.tar.gz"
    export SHA256="65bfd4a99925f1f85d712f4c1109977aa24ee4c6e198162bf8e819fdde19e875"
else
    export TAR="$VERSION.darwin-amd64.tar.gz"
    export SHA256="e49bf83ae10b2232d2efa918f0e9df1d76f93a0c6b0ea18c11edd9ef9defa505"
fi

if [ ! -e $TAR ]
then
   export TMPTAR=`mktemp`    
   curl https://dl.google.com/go/$TAR -o $TMPTAR
   mv $TMPTAR $TAR
fi

export COMPUTED=`openssl dgst -binary -sha256 $TAR | hexdump -ve '1/1 "%.2x"'`

if [ "$SHA256" != "$COMPUTED" ]
then
    echo "bad sha256"
    exit
fi

cp $TAR $TMP

cd $TMP

tar xf $TAR
export GOROOT=$TMP/go
mkdir gopath
export GOPATH=$TMP/gopath
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
echo "using: `go version`"

go get golang.org/x/tools/cmd/cover
go get golang.org/x/tools/cmd/godoc
go get golang.org/x/tools/cmd/stringer
go get golang.org/x/tools/cmd/goimports
go get golang.org/x/tools/cmd/gorename
go get golang.org/x/tools/cmd/callgraph
go get golang.org/x/tools/cmd/gomvpkg
go get golang.org/x/tools/cmd/guru
go get golang.org/x/lint/golint
go get github.com/dougm/goflymake
go get github.com/rogpeppe/godef
go get -u mvdan.cc/interfacer

cd $GOPATH

git clone --quiet https://github.com/dominikh/go-mode.el.git
cd go-mode.el
git checkout --quiet 99b06da

mkdir $GOROOT/misc/emacs
find $GOPATH -type f -name "*.el" -exec cp \{} $GOROOT/misc/emacs \;

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
if [ -e ~/go ]
then
    echo "mv ~/go `mktemp -d`"
fi
echo "mv $TMP/go ~/go"

