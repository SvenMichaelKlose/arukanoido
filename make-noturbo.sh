#!/bin/sh

sbcl --control-stack-size 256 --noinform --core bender/bender make-noturbo.lisp
