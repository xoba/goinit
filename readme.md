just a simple setup for my personal go language environment, based on
production versions of downloadable go, not custom builds.  for
automated setup on linux or darwin, you could try:

```
curl https://raw.githubusercontent.com/xoba/goinit/master/setup.sh | bash
```

then follow instructions on copying and pasting commands into your
terminal.  this shoud work on typical linux or darwin systems; no idea
how to automate this for windows o/s.

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
