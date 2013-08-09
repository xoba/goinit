#!/bin/bash
find $1 -name "*.go" -printf "%T+ %p\n" | sort | awk '{ print $2 }'
