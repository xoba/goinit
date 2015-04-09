#!/bin/bash
#
# sets up go, assumed to be in ~/go -- replaces .emacs!
#
# sudo aptitude update && sudo aptitude install -y emacs
cat >> ~/.bashrc <<EOF
export GOROOT=~/go
export PATH=$PATH:~/go/bin
EOF
cp ~/go/misc/emacs/.emacs ~/
