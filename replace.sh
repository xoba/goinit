#!/bin/bash
source goinit.sh
gofmt -w -l -s -r "$@" go/src
