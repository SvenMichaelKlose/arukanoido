# Arukanoido

Arukanoido is a clone of the famous arcade game "Arkanoid" for the
Commodore VIC–20 with at least 24K memory expansion.  It should be
played best with paddles, which are detected automatically as soon
as you move them.  If you don't have paddles Arukanoido switches
to a more convenient and slower joystick mode.

This demo comes with the first eight of 33 levels.

Don't play the WAV file without the volume turned down unless you
want your ears zonked.  Instead, you can record it on a music
cassette and slap that into a real VIC.

The IMG files are the banks of the cartridge version.  You can
fire them up with VICE like this:

```
xvic -cart2 arukanoido.img.aa -cart4 arukanoido.img.ab -cart6 arukanoido.img.ac -cartA arukanoido.img.ad
```

Arukanoido is being discussed and developed on the VIC–20 Denial forum:
http://sleepingelephant.com/ipw-web/bulletin/bb/viewtopic.php?t=3752

Get the latest revision here:
http://hugbox.org/pixel/software/vic-20/arukanoido/

If you wanna complain or are in for crazy small talk just mail to
Sven Michael Klose <pixel@hugbox.org>.


# Title screen keys

* H, J, K, L: Move screen around.
* F: Switch between landscape (NTSC) and portrait (PAL) format.
* M: Switch between beamrider's blasting VIC sounds or arcade digis.
* B: Start BASIC.


# In-game keys

* S, J: Move Vaus left.
* D. K: Move Vaus right.
* SPACE: Fire – doesn't work in combination with other key tough. :(
* P: Pause the game.

## Keys for game testers

* N: Skip to next level.
* 0: Drop random bonuses.
* 1: Drop bonus L only.
* 2: Drop bonus E only.
* 3: Drop bonus C only.
* 4: Drop bonus S only.
* 5: Drop bonus B only.
* 6: Drop bonus D only.
* 7: Drop bonus P only.


# Things missing

* Original movement of obstacles.
* DOH particles
* DOH animation
* intro/outro animations
* hiscore table


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

URL: https://bitbucket.org/magli143/exomizer/wiki/Home


# Contributions

This project has been initiated by Sabine Kuhn <eimer@devcon.net>.

Code has been contributed by Sven Michael Klose <pixel@hugbox.org>.

Tiles and sprites have been created with beamrider's VIC—20 Screen
and Character Designer:
http://sleepingelephant.com/ipw-web/bulletin/bb/viewtopic.php?f=14&t=7133

The DOH graphics have been contributed by Mike.  He created it
with his VIC–20 editor MINIPAINT (there must not be a ,1 in the LOAD command).

A demo title screen has been contributed by tokra with help of
Mike's MINIGRAFIK. Also no ,1 in the LOAD command.

VIC conversions of the original tunes and sounds have been contributed
by beamrider as well.


# External resources

https://en.wikipedia.org/wiki/Arkanoid/

https://tcrf.net/Arkanoid_(Arcade)
