#!/bin/bash
TMP=`mktemp`
sort $1 | uniq > $TMP
mv $TMP $1
