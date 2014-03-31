#!/bin/bash

#
# sets up go, assumed to be in ~/go
#

cat >> ~/.bashrc <<EOF
export GOROOT=~/go
export PATH=$PATH:$GOROOT/bin
if [ -f $GOROOT/misc/bash/go ]; then
    . $GOROOT/misc/bash/go
fi
EOF

cp ~/go/misc/emacs/.emacs ~/
