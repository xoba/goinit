#!/bin/bash
emacs -nw `./sourcefiles.sh` --eval "(add-hook 'emacs-startup-hook 'delete-other-windows)" 
