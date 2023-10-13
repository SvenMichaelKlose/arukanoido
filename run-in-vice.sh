#!/bin/sh

echo "Options you might want:"
echo
echo ".model -vic20pal"
echo ".model -vic20ntsc"

xvic -memory all -moncommands obj/arukanoido-disk.prg.lbl $@ arukanoido/arukanoido.prg
