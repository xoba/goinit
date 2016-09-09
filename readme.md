for building and installing a recent stable version of golang from scratch:

    curl https://raw.githubusercontent.com/xoba/goinit/master/buildgo.sh | bash

on amazon's stock linux ami, prior setup is simply:

    yum -y update
    yum -y install tmux emacs git hg libtool gcc patch glibc-static

setting up bashrc, emacs, etc (warning, replaces your .emacs file):

    curl https://raw.githubusercontent.com/xoba/goinit/master/setupgo.sh | bash
