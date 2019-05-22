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
version = "go1.12.5"
darwin_tar = "go1.12.5.darwin-amd64.tar.gz"
darwin_href = "https://dl.google.com/go/go1.12.5.darwin-amd64.tar.gz"
darwin_sha = "566d0b407f7d4aa5a1315988b562bbe4e9422a93ce2fbf27a664cddcb9a3e617"
linux_tar = "go1.12.5.linux-amd64.tar.gz"
linux_href = "https://dl.google.com/go/go1.12.5.linux-amd64.tar.gz"
linux_sha = "aea86e3c73495f205929cfebba0d63f1382c8ac59be081b6351681415f4063cf"
goinit$ 
```
