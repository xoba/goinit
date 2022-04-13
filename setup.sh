#!/bin/bash -e
#
# builds and installs a nice go language environment for emacs etc.
#

unset GOPATH
unset GOROOT

TMP=`mktemp -d`
echo "working in: $TMP"

PLATFORM="`uname`_`uname -p`"

case $PLATFORM in
    'Linux_x86_64')
	SHA=`cat versions/linux_x86_64_sha.txt`
	TAR=`cat versions/linux_x86_64_tar.txt`
	HREF=`cat versions/linux_x86_64_href.txt`
	;;
    'Darwin_i386')
	SHA=`cat versions/darwin_i386.sha.txt`
	TAR=`cat versions/darwin_i386.tar.txt`
	HREF=`cat versions/darwin_i386.href.txt`
	;;
    'Darwin_arm')
	SHA=`cat versions/darwin_arm.sha.txt`
	TAR=`cat versions/darwin_arm.tar.txt`
	HREF=`cat versions/darwin_arm.href.txt`
	;;
    *)
	echo "unsupported platform: $PLATFORM"; exit 1; 
	;;
esac

if [ ! -e $TAR ]
then
    TMPTAR=`mktemp`
    curl -L -o $TMPTAR $HREF
    mv $TMPTAR $TAR
fi

COMPUTED=`openssl dgst -sha256 $TAR | awk '{ print $NF }'`

if [ "$SHA" != "$COMPUTED" ]
then
    echo "bad sha256; got $COMPUTED, expected $SHA"
    rm -f $TAR
    exit
fi

cp $TAR $TMP
cd $TMP
tar xf $TAR

export GOROOT=$TMP/go
export GOPATH=$TMP/gopath
mkdir -p $GOPATH
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
echo "using: `go version`"

go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/cover@latest
go install golang.org/x/tools/cmd/godoc@latest
go install golang.org/x/tools/cmd/stringer@latest
go install golang.org/x/tools/cmd/goimports@latest
go install golang.org/x/tools/cmd/gorename@latest
go install golang.org/x/tools/cmd/callgraph@latest
go install golang.org/x/tools/cmd/gomvpkg@latest
go install golang.org/x/tools/cmd/guru@latest
go install golang.org/x/lint/golint@latest
go install github.com/dougm/goflymake@latest
go install github.com/rogpeppe/godef@latest
go install mvdan.cc/interfacer@latest

cd $GOPATH

git clone --quiet https://github.com/dominikh/go-mode.el.git
cd go-mode.el
git checkout --quiet 99b06da

mkdir $GOROOT/misc/emacs
find $GOPATH -type f -name "*.el" -exec cp \{} $GOROOT/misc/emacs \;

cp $GOPATH/bin/* $GOROOT/bin/

cat > $GOROOT/misc/emacs/.emacs <<EOF
(setq column-number-mode t)
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

