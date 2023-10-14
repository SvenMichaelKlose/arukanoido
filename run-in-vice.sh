#!/bin/sh

echo "Options you might want:"
echo
echo ".model -pal"
echo ".model -ntsc"

xvic -memory all -moncommands obj/arukanoido-disk.prg.lbl $@ arukanoido/arukanoido.prg
