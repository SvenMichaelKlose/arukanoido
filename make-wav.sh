#!/bin/sh

sbcl --noinform --core bender/bender make-wav.lisp
cp arukanoido*.zip NEWS ~/Desktop/hugbox.org/www/pixel/software/vic-20/arukanoido/
