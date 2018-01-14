#!/bin/sh

sbcl --noinform --core bender/bender make-wav.lisp
cp -v arukanoido*.zip NEWS ~/Desktop/hugbox.org/www/pixel/software/vic-20/arukanoido/
cp -v README.md ~/Desktop/hugbox.org/www/pixel/software/vic-20/arukanoido/README.txt
