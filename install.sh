#!/bin/bash
source goinit.sh $1
./genbuild.sh $1
go install $MAIN
exit $?

