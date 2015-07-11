#!/bin/bash
#
# profile is $1, bucket is $2
#
cd ~/goinit
echo "`date` starting $1 $2" >> log.txt
make
cd go
git checkout master
git pull
cd ..
export PATH=$PATH:/usr/local/bin
source <(./ec2 -profile $1 -gen $2) 2>&1 | tee -a log.txt
echo "`date` done $1 $2" >> log.txt
