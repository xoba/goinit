#!/bin/bash
source goinit.sh
find . -name "*~" -exec rm \{} \; 
rm -rf go/bin
rm -rf go/pkg
