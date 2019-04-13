#!/bin/bash -e
#
# tries to get latest version and sha256 hashes from golang website
#
export GOPATH=`pwd`
go run src/xoba/goinit/version.go
