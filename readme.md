for building and installing a recent stable version of golang from scratch:

    curl https://raw.githubusercontent.com/xoba/goinit/master/buildgo.sh | bash

or to just grab the tgz'd file:
 
    tar xf `curl https://raw.githubusercontent.com/xoba/goinit/master/buildgo.sh | bash | tail -1`

setting up bashrc, emacs, etc (warning, replaces your .emacs file):

    curl https://raw.githubusercontent.com/xoba/goinit/master/setupgo.sh | bash
