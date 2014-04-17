#!/bin/bash

# simplest, vanilla golang build

cd ~/

sudo aptitude update && sudo aptitude install -y gcc libc6-dev mercurial libtool emacs git make

cat >> ~/.hgrc <<EOF
[web]
cacerts = /etc/ssl/certs/ca-certificates.crt
EOF

export GOROOT=~/go
export GOPATH=`mktemp -d`
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

time hg clone https://code.google.com/p/go

cat >> go/.hg/hgrc <<EOF
[extensions]
codereview = ~/go/lib/codereview/codereview.py
[ui]
username = Mike Andrews <mra@xoba.com>
EOF

cd ~/go/src

time ./all.bash


