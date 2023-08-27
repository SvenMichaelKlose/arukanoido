#!/bin/sh

rm arukanoido.zip arukanoido/*
git log --oneline | wc -l >_revision
sbcl --control-stack-size 24000 --noinform --core bender/bender make.lisp
