#!/bin/sh

rm arukanoido.zip arukanoido/*
git log --oneline | wc -l >_revision
sbcl --noinform --core bender/bender make.lisp
