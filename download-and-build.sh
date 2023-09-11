#!/bin/sh

# Launch this file in an empty directory to download, build and
# install tré, Bender and Arukanoido.
#
# You must have git, sbcl and sox installed.
# Debian-based: sudo apt install git sbcl sox

set -e

git clone https://github.com/SvenMichaelKlose/tre
git clone https://github.com/SvenMichaelKlose/bender
git clone https://github.com/SvenMichaelKlose/arukanoido
cd tre; ./make.sh core; ./make.sh install; cd ..
ln -s ../tre/environment bender/
cd bender; ./make.sh; cd ..
ln -s ../bender arukanoido/
cd arukanoido; ./make.sh; cd ..
