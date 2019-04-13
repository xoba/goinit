#!/bin/bash -e
#
# builds and installs a nice go language environment for emacs etc.
#

./fetch.sh

VERSION=`cat version.txt`

TMP=`mktemp -d`
echo "working in: $TMP"

PLATFORM=`uname`

case $PLATFORM in
    'Linux')
	SHA=`cat linux_sha.txt`
	TAR=`cat linux_tar.txt`
	HREF=`cat linux_href.txt`
	;;
    'Darwin')
	SHA=`cat darwin_sha.txt`
	TAR=`cat darwin_tar.txt`
	HREF=`cat darwin_href.txt`
	;;
    *)
	echo "unsupported platform: $PLATFORM"; exit 1; 
	;;
esac

if [ ! -e $TAR ]
then
   TMPTAR=`mktemp`    
   curl $HREF -o $TMPTAR
   mv $TMPTAR $TAR
fi

COMPUTED=`openssl dgst -sha256 $TAR | awk '{ print $NF }'`

if [ "$SHA" != "$COMPUTED" ]
then
    echo "bad sha256; got $COMPUTED, expected $SHA"
    exit
fi

cp $TAR $TMP

cd $TMP

tar xf $TAR
GOROOT=$TMP/go
mkdir gopath
GOPATH=$TMP/gopath
PATH=$GOROOT/bin:$GOPATH/bin:$PATH
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

