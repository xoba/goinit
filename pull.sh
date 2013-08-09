#!/bin/bash

#
# run this to wipe goutil, pull in latest from github
#
source goinit.sh
rm -rf ./go/src/github.com/xoba/goutil
go get github.com/xoba/goutil
