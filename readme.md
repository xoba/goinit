just a simple setup for my personal go language environment, based on
official versions of downloadable go, not custom builds like i used to
do. for automated setup on linux or darwin, you could try:

```
git clone git@github.com:xoba/goinit.git
cd goinit
./setup.sh
```

then follow instructions on copying and pasting commands into your
terminal.

the minimal'ish set of environment variables would be:

```
export GOROOT=~/go
export PATH=$GOROOT/bin:$PATH
```

then also for emacs mode:

```
ln -s $GOROOT/misc/emacs/.emacs ~/.emacs
```

additionally for darwin:

```
alias emacs="/Applications/Emacs.app/Contents/MacOS/Emacs"
```

no idea how to automate this for non-unix operating systems.

run `fetch.sh` to update our impression of which version of go to focus on:
```
goinit$ ./fetch.sh -help
Usage of bin/fetch:
  -v	whether to be verbose or not
goinit$ ./fetch.sh -v
version = "go1.12.4"
darwin_tar = "go1.12.4.darwin-amd64.tar.gz"
darwin_href = "https://dl.google.com/go/go1.12.4.darwin-amd64.tar.gz"
darwin_sha = "50af1aa6bf783358d68e125c5a72a1ba41fb83cee8f25b58ce59138896730a49"
linux_tar = "go1.12.4.linux-amd64.tar.gz"
linux_href = "https://dl.google.com/go/go1.12.4.linux-amd64.tar.gz"
linux_sha = "d7d1f1f88ddfe55840712dc1747f37a790cbcaa448f6c9cf51bbe10aa65442f5"
goinit$ 
```
