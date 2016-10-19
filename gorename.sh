#!/bin/bash
#
# script to test go-rename all by itself from scratch
#
# i ran it on the standard "Amazon Linux AMI 2016.09.0 (HVM), SSD Volume Type - ami-c481fad3", but should work similarly on any linux box
#
cd
yum -y install tmux emacs git hg libtool gcc patch glibc-static
wget https://storage.googleapis.com/golang/go1.7.1.linux-amd64.tar.gz
tar xf go1.7.1.linux-amd64.tar.gz
export GOROOT=`pwd`/go
export GOPATH=`pwd`
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
go get golang.org/x/tools/cmd/gorename
git clone https://github.com/dominikh/go-mode.el.git
mkdir go/misc/emacs
find . -type f -name "*.el" -exec cp \{} ~/go/misc/emacs \;
cat > ~/.emacs <<EOF
(add-to-list 'load-path "~/go/misc/emacs/" t)
(require 'go-rename)
EOF
cat > ~/test.go <<EOF
package main

import "fmt"

func main() {
        var x string
        x = "abc"
        fmt.Println(x)
}
EOF

#
# run "go-rename" on var x, and you'll get this error:
#
# Symbol's function definition is void: list*
#





