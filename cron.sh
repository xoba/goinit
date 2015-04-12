#!/bin/bash
#
# profile is $1, bucket is $2
#
cd ~/goinit
echo "date $1 $2" > log.txt
cd go
git pull
cd ..
source <(go run ec2.go -profile $1 -gen $2)


