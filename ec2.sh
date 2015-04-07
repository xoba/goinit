#!/bin/bash
aws ec2 run-instances --image-id ami-ee793a86 --instance-type m3.xlarge --key-name golang_rsa
