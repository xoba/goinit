for initializing a go project with filesystem, scripts, etc:

    curl https://raw.github.com/xoba/goinit/master/setup.sh | sh

for building golang from scratch:

    source <(curl https://raw.githubusercontent.com/xoba/goinit/master/buildgo.sh) | tee log.txt

setting up bashrc, emacs, etc:

    source <(curl https://raw.githubusercontent.com/xoba/goinit/master/setupgo.sh)
