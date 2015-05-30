#!/bin/bash

# configure machine:
aptitude update && aptitude install -y awscli curl libc6-i386 gcc libc6-dev mercurial git libtool make pkg-config emacs ntp
mkdir -p ~/.aws
cat > ~/.aws/config <<EOF
[default]
aws_access_key_id = {{.accessKey}}
aws_secret_access_key = {{.secretKey}}
region = us-east-1
output = json
EOF

# build go:
git clone https://github.com/xoba/goinit.git
cd goinit
./buildgo.sh {{.commit}}

# upload artifacts:
cd ~/
{{ if .s3gz }}if [ -f go.tar.gz ]; then
    aws s3 cp go.tar.gz {{.s3gz}}
{{if .latest}}
cat > latest.sh <<EOF
#!/bin/bash
#
# {{.comment}}
#
wget -N {{.s3gzurl}}
rm -rf go
tar xf {{.s3gzkey}}
{{.newgo}}
EOF
aws s3 cp latest.sh {{.latest}}
{{end}}
fi
{{end}}
{{ if .s3log }}aws s3 cp log.txt {{.s3log}}
{{end}}

# wrap-up:
{{ if .terminate}}aws ec2 terminate-instances --instance-ids `curl http://169.254.169.254/latest/meta-data/instance-id`
{{end}}
