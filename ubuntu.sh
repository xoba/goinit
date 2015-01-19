#!/bin/bash
#
# prepare a virgin ubuntu box for buildgo.sh
#
sudo aptitude update && sudo aptitude install -y libc6-i386 gcc libc6-dev mercurial git libtool make pkg-config emacs
