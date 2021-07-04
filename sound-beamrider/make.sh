set -e
set -v

mkdir -p bin
rm -f bin/*
mkdir -p obj
rm -f obj/*

#ca65 --listing obj/basic.lst --include-dir . -g -o obj/basic.o src/basic.s
ca65 --listing obj/music.lst --include-dir . -g -o obj/music.o src/music.i
ca65 --listing obj/main.lst --include-dir . -g -o obj/main.o src/main.s
ca65 --listing obj/player.lst --include-dir . -g -o obj/player.o src/player.s

ld65 -C /usr/local/share/cc65/cfg/vic20-32k.cfg -Ln bin/arukanoido.sym -m bin/arukanoido.map -o bin/arukanoido.prg obj/main.o obj/player.o obj/music.o /usr/local/share/cc65/lib/vic20.lib
ld65 -C bin.cfg -Ln bin/bin.sym -m bin/bin.map -o bin/bin.bin obj/player.o obj/music.o
