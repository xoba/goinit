#!/bin/bash -e
#
# tries to get latest version and sha256 hashes from golang website
#
export GOPATH=`pwd`
go install xoba/fetch
bin/fetch "$@"

