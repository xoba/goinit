#!/bin/bash -e

#
# creates go.tar.gz, a nice customized golang.org distribution for linux
#

export GOROOT_FINAL=~/go

function tmp() {
    echo `mktemp -d /tmp/go_XXXXXXXXXXXX`
}

if [ -z "$TMP" ]; then
    export TMP=$(tmp)
fi

echo "working in $TMP"
cd $TMP

# if you need to setup an ubuntu box, uncomment the following:
# sudo aptitude update && sudo aptitude install -y gcc libc6-dev mercurial git libtool make pkg-config emacs

export GOROOT=$TMP/go
export GOPATH=$(tmp)
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
# export GO_DISTFLAGS="-s"

hg clone https://code.google.com/p/go

cd $TMP/go/src
hg update 8ff3b7315209

./all.bash 2>&1 | tee $TMP/log.txt

go get code.google.com/p/go.tools/cmd/goimports
go get code.google.com/p/go.tools/cmd/present
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

mkdir -p ../misc/emacs
git clone https://github.com/dominikh/go-mode.el.git
cd go-mode.el
emacs -batch --eval "(let ((generated-autoload-file \"$(pwd)/go-mode-load.el\")) (update-directory-autoloads \".\"))"
mv go-mode.el ../../misc/emacs
mv go-mode-load.el ../../misc/emacs
cd ..
rm -rf go-mode.el

# remove a file with syntax errors
rm -f $GOPATH/src/code.google.com/p/rog-go/exp/abc/audio/output.go

cp $GOPATH/src/github.com/dougm/goflymake/*.el $GOROOT/misc/emacs/
cp $GOPATH/src/github.com/golang/lint/misc/emacs/*.el $GOROOT/misc/emacs/
cp $GOPATH/bin/* $GOROOT/bin/
mv $GOPATH/src/code.google.com $GOROOT/src

cat > $GOROOT/misc/emacs/.emacs <<EOF
(set-face-attribute 'default nil :height 120)
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

export GOOS=darwin
export GOARCH=amd64
./make.bash --no-clean 2>&1 | tee -a $TMP/log.txt
rm -rf $TMP/go/bin/darwin_amd64/

export GOOS=windows
export GOARCH=amd64
./make.bash --no-clean 2>&1 | tee -a $TMP/log.txt
rm -rf $TMP/go/bin/windows_amd64/

#export GOOS=linux
#export GOARCH=arm
#./make.bash --no-clean 2>&1 | tee -a $TMP/log.txt
#rm -rf $TMP/go/bin/linux_arm/

unset GOOS
unset GOARCH
unset GOROOT
unset GOPATH

rm -rf $GOPATH

cd $TMP
echo "results in $TMP"

if grep -Fxq "ALL TESTS PASSED" log.txt
then
    echo "all tests passed"
    tar cf go.tar go
    gzip -f go.tar
    rm -rf go
    echo $TMP/go.tar.gz
    exit 0
else
    echo "tests failed, produced nothing"
    exit 1
fi

