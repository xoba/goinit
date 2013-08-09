#!/bin/bash

source config.txt

# sourcedir solution from http://www.mpdaugherty.com/blog/find-the-current-bash-directory-in-any-script/

SOURCE_TEMP=$SOURCE
DIR_TEMP=$DIR

SOURCE="${BASH_SOURCE[0]}"
# Go through all symlinks to find the ultimate location of the source file
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
# Get an absolute path to the directory that contains this file
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

export GOROOT=~/go
export GOPATH=$DIR/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH

SOURCE=$SOURCE_TEMP
DIR=$DIR_TEMP

case $1 in
    darwin)
	export GOOS=darwin
	export GOARCH=amd64
	;;
    windows)
	export GOOS=windows
	export GOARCH=amd64
	;;
    *)
	export GOOS=linux
	export GOARCH=amd64
	;;
esac
