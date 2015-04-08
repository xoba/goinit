#!/bin/bash
#
# lanunches ec2 build of go
#
aws ec2 run-instances --image-id ami-ee793a86 --instance-type m3.xlarge --key-name golang_rsa --user-data file://ec2-cloudinit.sh
