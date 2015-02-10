#!/bin/bash
#
# build go inside a virgin ubuntu vagrant box
#
aptitude update && aptitude install -y curl libc6-i386 gcc libc6-dev mercurial git libtool make pkg-config emacs ntp
/etc/init.d/ntp stop
ntpd -gq
/etc/init.d/ntp start
time /vagrant/buildgo.sh
