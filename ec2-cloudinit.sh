#!/bin/bash
aptitude update && aptitude install -y curl libc6-i386 gcc libc6-dev mercurial git libtool make pkg-config emacs ntp
git clone git@github.com:xoba/goinit.git
