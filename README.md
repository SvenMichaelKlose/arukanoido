ARUKANOIDO – an Arkanoid clone for the Commodore VIC-20
=======================================================


# Overview

ARUKANOIDO is a clone of the famous arcade game "Arkanoid" for the
Commodore VIC–20 with at least 24K memory expansion.  Additional
+32K will enable original arcade sounds (when debugged).

## WAV file for real tapes

Don't play the WAV file without the volume turned down unless you
want your ears zonked.  Instead, you can record it on a music
cassette and slap that into a real VICs C2N drive.  Loads at
5.6kbit/s.

# Controls

## Joystick or paddles

Hitting fire in the title screen will start a new game or skip the
intro.

ARUKANOIDO should be played with paddles.  They are detected
automatically as soon as you move them at the beginning of a new game.
If you don't have paddles ARUKANOIDO sticks with a slower mode to keep
the game playable.

### Playing with emulator and mouse as replacement for paddles

If you're playing this in an emulator with a mouse as a replacement
for paddles, make sure to switch off your desktop's mouse
acceleration or it'll drive you nuts!

### Title screen keys

* 1: Start one player game.
* 2: Start twp player game. (experimental)
* SPACE: Start game.
* H, J, K, L: Move screen around.
* F: Switch between landscape (NTSC) and portrait (PAL) format.
* M: Switch between beamrider's blasting VIC sounds or arcade digis.
* T: Jump to highscore table.
* B: Quit and start BASIC.

### In-game keys

* P: Pause the game.
* C: Display the current charset (NTSC only).
* M: Toggle VIC/original sounds.

# Keys for game testers (compiled with debug mode enabled)

* N: Warop to next level.
* 0: Drop random bonuses.
* 1: Drop bonus L only.
* 2: Drop bonus E only.
* 3: Drop bonus C only.
* 4: Drop bonus S only.
* 5: Drop bonus B only.
* 6: Drop bonus D only.
* 7: Drop bonus P only.
* C: Pause game nad how character map.
* L: Set number of lives to ten.

# More information

Arukanoido is being discussed on the VIC–20 Denial forum:
http://sleepingelephant.com/ipw-web/bulletin/bb/viewtopic.php?t=3752

# Contributions

This project has been initiated by Sabine Kuhn <eimer@devcon.net>.

Code and graphics mostly done by Sven Michael "pixel" Klose 
<pixel@hugbox.org>.  Tiles and sprites have been created with beamrider's
VIC—20 Screen and Character Designer and VIM.
http://sleepingelephant.com/ipw-web/bulletin/bb/viewtopic.php?f=14&t=7133

VIC conversions of the original tunes and sounds have been contributed
by Adrian "beamrider" Fox.

Cover art and top-level screen lettering has been contributed by Bryan
"darkatx" Henry.

The DOH graphics have been contributed by Michael "Mike" Kircher.  He
created them using his VIC–20 editor MINIPAINT (there must NOT be a ,1 in
the LOAD command).
Mike also contributed raster interrupt synchronisation code.

A demo title screen has been contributed by Torsten "tokra" Kracke with
help of Mike's MINIGRAFIK. (Also no ,1 in the LOAD command.)


# Applications used

## beamrider's "VIC–20 Screen and Character Designer"

URL: http://87.81.155.196/vic20sdd/Vic20SDD.htm
Discussion: http://sleepingelephant.com/ipw-web/bulletin/bb/viewtopic.php?f=14&t=7133

## Mike's "MINIPAINT" and "MINIGRAFIK"

URL: https://cid-05ef0a8eae2a4f4a.onedrive.live.com/self.aspx/.Public/denial/minigrafik/
Discussion: http://sleepingelephant.com/ipw-web/bulletin/bb/viewtopic.php?t=7584

## pixel's assembler "bender"

URL: https://github.com/SvenMichaelKlose/bender/
Discussion: http://sleepingelephant.com/ipw-web/bulletin/bb/viewtopic.php?f=2&t=7072


# Other applications

## VICE – the Versatile Commodore Emulator

URL: http://vice-emu.sourceforge.net/

## exomizer

Data has been compressed using exomizer v2.0.10 by Magnus Lind.
URL: https://bitbucket.org/magli143/exomizer/wiki/Home


# External resources

https://en.wikipedia.org/wiki/Arkanoid/

https://tcrf.net/Arkanoid_(Arcade)
