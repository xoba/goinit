#!/bin/bash

# simplest, vanilla golang build

sudo aptitude update && sudo aptitude install -y gcc libc6-dev mercurial libtool emacs git make

time hg clone https://code.google.com/p/go
cd go/src
time ./all.bash


