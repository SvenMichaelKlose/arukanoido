#!/bin/sh

sbcl --noinform --core bender/bender make-wav.lisp
rm tap2wav.tmp
