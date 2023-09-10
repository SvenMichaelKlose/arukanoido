ARUKANOIDO internals
====================

# Ball directions

There are 256 directions derived from a sine table of the
same size.  Only eight of them are used for the ball and
for moving the obstacles.  Full resolution is used to aim
the DOHs bullets at the Vaus.

Direction 0 points South and goes counter-clockwise with
increments.

¨¨¨
      $80
       |
       |
$c0 ---+--- $40
       |
       |
      $00
¨¨¨

## Used ball and obstacle directions

These are the values for the eight ball and obstacle
directions which have their own index to make some
calculations much simpler:

Index | Direction          | Sine table index
---------------------------------------------
0     | Shallow North-West | $a9
1     | Steep North-West   | $94
2     | Steep North-East   | $6c
3     | Shallow North-East | $57 
4     | Shallow South-East | $29
5     | Steep South-East   | $14
6     | Steep South-West   | $ec
7     | Shallow South-West | $d7

# Sprites

Sprites are drawn using dynamically allocated chars.  The charset
is split in halves that are switched for each new frame.  New
sprites are drawn over the old frame, then sprite chars of the
former frame are erased or restored.  Each half of the charset
is further split into halves.  The first halves is for the sprites
and the second half is for the foreground and background.  Foreground
chars cannot be overdrawn by sprites, background chars can.

Charactre index | Function
---------------------------------------
$00-$3f         | Frame 0 sprites
$40-$5f         | Frame 0 foreground
$60-$7f         | Frame 0 background
$80-$bf         | Frame 1 sprites
$c0-$df         | Frame 1 foreground
$e0-$ff         | Frame 1 background

In ARUKANOIDO background chars are used for the DOH only, so its
bullets can be seen.  They are not used for the bricks because of
inevitable colour clashes which would ruin the looks of the game.
