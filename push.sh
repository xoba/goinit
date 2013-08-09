#!/bin/bash

#
# take local changes from go/src/github.com/xoba/goutil 
# and enable push to github
#

DIR=/tmp/`mktemp -u git_XXXXXXXXXX`
echo $DIR
mkdir -p $DIR
pushd $DIR > /dev/null
git clone git@github.com:xoba/goutil.git > /dev/null

popd > /dev/null
rsync --delete --exclude=.git -az go/src/github.com/xoba/goutil $DIR

cd $DIR
cd goutil

git status
