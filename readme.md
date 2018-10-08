just a simple setup for my go language environment, based on production
versions of downloadable go, not custom builds.
for automated setup, you could try:

```
curl https://raw.githubusercontent.com/xoba/goinit/master/setup.sh | bash
```

then follow instructions on copying and pasting commands into your terminal.
this shoud work on typical linux or mac systems.

the minimal'ish set of environment variables would be:

```
export GOROOT=~/go
export PATH=$GOROOT/bin:$PATH
```


