#!/bin/bash
aptitude update && aptitude install -y curl libc6-i386 gcc libc6-dev mercurial git libtool make pkg-config emacs ntp
git clone https://github.com/xoba/goinit.git
cd goinit
./buildgo.sh
