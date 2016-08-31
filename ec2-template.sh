#!/bin/bash

# configure machine:
yum -y update
yum -y install tmux emacs git hg libtool gcc patch glibc-static
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
#!/bin/bash -e
#
# {{.comment}}
#
wget -N {{.s3gzurl}}
mv go go.old
tar xf {{.s3gzkey}}
{{.newgo}}
rm -rf go.old
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
