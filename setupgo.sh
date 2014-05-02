#!/bin/bash

#
# sets up go, assumed to be in ~/go
#

sudo aptitude update && sudo aptitude install -y emacs

cat >> ~/.bashrc <<EOF
export GOROOT=~/go
export PATH=$PATH:~/go/bin
if [ -f ~/go/misc/bash/go ]; then
    . ~/go/misc/bash/go
fi
EOF

cp ~/go/misc/emacs/.emacs ~/
