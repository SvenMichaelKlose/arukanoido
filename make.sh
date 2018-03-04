#!/bin/sh

git log --oneline | wc -l >_revision
sbcl --control-stack-size 256 --noinform --core bender/bender make.lisp
