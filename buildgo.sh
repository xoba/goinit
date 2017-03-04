#!/bin/bash -e

#
# first argument is commit to checkout, or nothing
#
# creates go.tar.gz, a nice customized golang.org distribution for linux with emacs support
#

cd ~/

export GOROOT=~/go
export GOPATH=/tmp/gopath
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH

git clone https://go.googlesource.com/go

#
# enable larger heap size
#
sed -i -e 's/*39/*41/g' go/src/runtime/malloc.go
echo "// changed 39 to 41 (bits) in this file to enable 2048 GB heap" >> go/src/runtime/malloc.go
sed -i -e 's/sys.TheVersion/sys.TheVersion+" (41 bits heap)"/g' go/src/runtime/extern.go

# build bootstrap go
git clone go go1.4
cd go1.4/src
git checkout go1.4.3
time ./make.bash
cd ..
export GOROOT_BOOTSTRAP=`pwd`

cd ~/go/src

if (( $# > 0 )); then
    git checkout $1
fi

time ./all.bash 2>&1 | tee ~/log.txt

# official ones:
go get golang.org/x/tools/cmd/cover
go get golang.org/x/tools/cmd/godoc
go get golang.org/x/tools/cmd/stringer
go get golang.org/x/tools/cmd/goimports
# delete gotype due to deletion by https://github.com/golang/tools/commit/f5a6ee1ea9f7b3a91e3e70dc1b9706886d0e0ae3
# "cmd/gotype: delete this command in favor of go/types/gotype.go in the std lib"
# go get golang.org/x/tools/cmd/gotype
go get golang.org/x/tools/cmd/gorename
go get golang.org/x/tools/cmd/callgraph
go get golang.org/x/tools/cmd/gomvpkg
go get golang.org/x/tools/cmd/guru

# semi-official:
go get github.com/golang/lint/golint

# unofficial:
go get github.com/dougm/goflymake
go get github.com/rogpeppe/godef # github.com/zenoss/rog-go/exp/cmd/godef
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

unset GOOS
unset GOARCH
unset GOROOT
unset GOPATH

rm -rf $GOPATH

cd ~/

if grep -Fxq "ALL TESTS PASSED" log.txt
then
    echo "all tests passed"
    cp log.txt go
    tar cf go.tar go
    gzip -f go.tar
    rm -rf go
    exit 0
else
    echo "tests failed, produced nothing"
    exit 1
fi

