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
go get golang.org/x/tools/cmd/gotype
go get golang.org/x/tools/cmd/gorename
go get golang.org/x/tools/cmd/callgraph
go get golang.org/x/tools/cmd/gomvpkg
go get golang.org/x/tools/cmd/guru

# semi-official:
go get github.com/golang/lint/golint

# unofficial:
go get github.com/dougm/goflymake
go get github.com/rogpeppe/godef # github.com/zenoss/rog-go/exp/cmd/godef

mkdir -p ../misc/emacs
git clone https://github.com/dominikh/go-mode.el.git
cd go-mode.el
emacs -batch --eval "(let ((generated-autoload-file \"$(pwd)/go-mode-load.el\")) (update-directory-autoloads \".\"))"
mv go-mode.el ../../misc/emacs
mv go-mode-load.el ../../misc/emacs
cd ..
rm -rf go-mode.el

# TODO: copy go-guru emacs to misc/emacs as well... also, update .emacs file

# remove a file with syntax errors
rm -f $GOPATH/src/github.com/zenoss/rog-go/exp/abc/audio/output.go

find $GOPATH -name "*.el" -exec cp \{} $GOROOT/misc/emacs/ \;

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

