#!/bin/bash
export GO1=`./gofiles.sh go/src | xargs`
echo *.sh version.txt $GO1
