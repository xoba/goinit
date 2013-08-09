#!/bin/bash
export PWD=`pwd`
emacs `./sourcefiles.sh` --geometry 150x83 --eval "(add-hook 'emacs-startup-hook 'delete-other-windows)" --title "`basename $PWD` ide" &

