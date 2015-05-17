#!/bin/bash
#
# profile is $1, bucket is $2
#
cd ~/goinit
echo "`date` starting $1 $2" >> log.txt
cd go
git pull
cd ..
source <(./ec2 -profile $1 -gen $2) 2>&1 | tee -a log.txt
echo "`date` done $1 $2" >> log.txt
