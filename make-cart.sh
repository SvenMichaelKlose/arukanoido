#!/bin/bash

printf '\x00\x20' >arukanoido/arukanoido123.img
cat arukanoido/arukanoido.img.a[a-c] >> arukanoido/arukanoido123.img
printf '\x00\xa0' >arukanoido/arukanoido5.img
cat arukanoido/arukanoido.img.ad >> arukanoido/arukanoido5.img
