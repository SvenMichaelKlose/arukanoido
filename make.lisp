(load "gen-vcpu-tables.lisp")

(var *demo?* t)
(var *shadowvic?* nil)
(var *rom?* nil)
(var *add-charset-base?* t)
(var *show-cpu?* nil)
(var *debug?* nil)
(var *revision* (!= (fetch-file "_revision")
                  (subseq ! 0 (-- (length !)))))

(var *audio-rate* 4000)

(unix-sh-mkdir "obj")

(fn make-filtered-wav (name rate)
  (sb-ext:run-program "/usr/bin/sox"
                      `(
                        "-v 0.9"
                        ,(+ "media/audio/" name ".wav")
                        ,(+ "obj/" name ".filtered.wav")
;                        "bass" "12"
                        "lowpass" ,(princ (half rate) nil)
;"compand" "0.3,1" "6:-70,-60,-20" "-5" "-90" ; podcast
"compand" "0.1,0.3" "-60,-60,-30,-15,-20,-12,-4,-8,-2,-7" "-2" ; voice/music
;"compand" "0.01,1" "-90,-90,-70,-70,-60,-20,0,0" "-5" ; voice/radio
                        )
                       :pty cl:*standard-output*))

(fn downsampled-audio-name (name)
  (+ "obj/" name ".downsampled.wav"))

(fn make-conversion (name rate)
  (sb-ext:run-program "/usr/bin/sox"
                      (list (+ "obj/" name ".filtered.wav")
                            "-c" "1"
                            "-b" "16"
                            "-r" (princ rate nil)
                            (downsampled-audio-name name))
                      :pty cl:*standard-output*))

(fn trim-wav (x)
  (? (== x. .x.)
     (trim-wav .x)
     x))

(fn read-wav (in)
  (= (stream-track-input-location? in) nil)
  (adotimes 96 (read-byte in))
  (with-queue q
    (awhile (read-word in)
            (queue-list q)
      (enqueue q (bit-xor ! 32768)))))

(fn wav2mon (out in f)
  (@ (! in)
    (write-word (* (integer (/ (bit-xor ! 32768) f)) f) out)))

(fn wav2raw (out in f m)
  (with-queue q
    (@ (! in)
      (enqueue q (* (integer (/ ! f)) m)))
    (@ (i (reverse (trim-wav (reverse (trim-wav (queue-list q))))))
      (write-byte (+ i (* 11 16)) out))))

(fn smallest (x)
  (let v 65535
    (@ (i x v)
      (when (< i v)
        (= v i)))))

(fn biggest (x)
  (let v 0
    (@ (i x v)
      (when (> i v)
        (= v i)))))

(fn exomize-stream (to from)
  (sb-ext:run-program "/usr/local/bin/exomizer" (list "raw" "-B" "-m" "256" "-M" "256" "-o" to from)
                      :pty cl:*standard-output*))

(fn convert-wavs (x d m)
  (@ (i x)
    (with-input-file in (+ "obj/" i ".downsampled.wav")
       (with (wav (read-wav)
              lo  (smallest wav)
              hi  (biggest wav)
              rat (/ 65535 (- hi lo))
              lwav  (@ #'integer (@ [* _ rat] (@ [- _ lo] wav))))
         (with-output-file out (+ "obj/" i ".mon")
           (wav2mon out lwav d))
         (with-output-file out (+ "obj/" i ".raw")
           (wav2raw out lwav d m))
         (exomize-stream (+ "obj/" i ".exm") (+ "obj/" i ".raw"))))))

(const *audio-2bit*
       '("break-out"
;        "catch"     ; Play beginning of reflection_low instead.
;        "doh-dissolving"    ; Needs higher sample rate.
         "doh-intro"
         "explosion"
         "extension"
         "extra-life"
         "final"
         "game-over"
         "laser"
         "lost-ball"
;        "reflection-doh" ; Needs higher sample rate.
         "reflection-high"; Needs 4 bits.
         "reflection-low" ; Needs 4 bits.
         "reflection-med" ; Needs 4 bits.
         "round-intro"
;        "round-intro2"
         "round-start"))

(const *audio-3bit* nil)

(@ (i *audio-2bit*)
  (print i)
  (make-filtered-wav i *audio-rate*)
  (make-conversion i *audio-rate*))
;(convert-wavs *audio-1bit* 32768 8)    ; 1 bit
(convert-wavs *audio-2bit* 16384 4)     ; 2 bits
;(convert-wavs *audio-3bit* 8192 2)      ; 3 bits
;(convert-wavs *audio-4bit* 4096 1)      ; 4 bits

(fn gen-sprite-nchars ()
  (with-queue q
    (dotimes (a 8)
      (dotimes (b 8)
        (enqueue q (* a b))))
    (queue-list q)))

(fn ascii2pixcii (x)
  (@ [?
       (== 32 (char-code _))  (code-char 255)
       (alpha-char? _)        (code-char (+ (- (char-code _) (char-code #\A)) (get-label 'framechars)))
       _]
     (string-list x)))

(fn string4x8 (x)
  (@ [- (char-code _) 32] (string-list x)))

(fn make-reverse-patch-id ()
  (string4x8 (list-string (reverse (string-list "ARUKANOIDO PATCH")))))

(const *bricks* '(#\  #\w #\o #\c #\g #\r #\b #\p #\y #\x #\s))

(const *levels* `(

; Round 01
(4
"sssssssssssss"
"rrrrrrrrrrrrr"
"yyyyyyyyyyyyy"
"bbbbbbbbbbbbb"
"ppppppppppppp"
"ggggggggggggg")

; Round 02
(2
"w            "
"wo           "
"woc          "
"wocg         "
"wocgr        "
"wocgrb       "
"wocgrbp      "
"wocgrbpy     "
"wocgrbpyw    "
"wocgrbpywo   "
"wocgrbpywoc  "
"wocgrbpywocg "
"ssssssssssssr")

; Round 03
(3
"ggggggggggggg"
"             "
"wwwxxxxxxxxxx"
"             "
"rrrrrrrrrrrrr"
"             "
"xxxxxxxxxxwww"
"             "
"ppppppppppppp"
"             "
"bbbxxxxxxxxxx"
"             "
"ccccccccccccc"
"             "
"xxxxxxxxxxccc")

; Round 04
(4
" ocgsb ywocg "
" cgsby wocgs "
" gsbyw ocgsb "
" sbywo cgsbp "
" bywoc gsbpy "
" ywocg sbpyw "
" wocgs bpywo "
" ocgsb pywoc "
" cgsbp ywocg "
" gsbpy wocgs "
" sbpyw ocgsb "
" bpywo cgsbp "
" pywoc gsbpy "
" ywocg sbpyw")

; Round 05
(2
"   y     y   "
"   y     y   "
"    y   y    "
"    y   y    "
"   sssssss   "
"   sssssss   "
"  ssrsssrss  "
"  ssrsssrss  "
" sssssssssss "
" sssssssssss "
" sssssssssss "
" s sssssss s "
" s s     s s "
" s s     s s "
"    ss ss    "
"    ss ss")

; Round 06
(4
"b r g c g r b"
"b r g c g r b"
"b r g c g r b"
"b r g c g r b"
"b r g c g r b"
"b xoxoxoxox b"
"b r g c g r b"
"b r g c g r b"
"b r g c g r b"
"b r g c g r b"
"o o x o x o o"
"b r g c g r b")

; Round 07
(4
"     yyp     "
"    yyppb    "
"   yyppbbr   "
"   yppbbrr   "
"  yppbbrrgg  "
"  ppbbrrggc  "
"  pbbrrggcc  "
"  bbrrggcco  "
"  brrggccoo  "
"  rrggccoow  "
"   ggccoow   "
"   gccooww   "
"    cooww    "
"     oww")

; Round 08
(4
"   x x x x   "
" x         x "
" xx x   x xx "
"      w      "
" x   xox   x "
"   x  c  x   "
"      g      "
"   x  r  x   "
" x   xbx   x "
"      p      "
" xx x   x xx "
" x         x "
"   x x x x")

; Round 09
,@(unless *demo?* `(
(2
" x x     x x "
" xgx     xgx "
" xcx     xcx "
" xxx     xxx "
"             "
"    pwwwy    "
"    poooy    "
"    pcccy    "
"    pgggy    "
"    prrry    "
"    pbbby")

; Round 10
(0
" x           "
"             "
" x           "
" x           "
" x           "
" x     b     "
" x    bcb    "
" x   bcwcb   "
" x  bcwcwcb  "
" x bcwcscwcb "
" x  bcwcwcb  "
" x   bcwcb   "
" x    bcb    "
" x     b     "
" x           "
" x           "
" x           "
" xxxxxxxxxxxx")

; Round 11
(4
" sssssssssss "
" s         s "
" s sssssss s "
" s s     s s "
" s s sss s s "
" s s s s s s "
" s s sss s s "
" s s     s s "
" s sssssss s "
" s         s "
" sssssssssss")

; Round 12
(4
"xxxxxxxxxxxxx"
"    x     xp "
" xw x     x  "
" x  x  x  x  "
" x  xg x  x  "
" x  x  x  x  "
" x ox  x bx  "
" x  x  x  x  "
" x  x  x  x  "
" x  x rx  x  "
" x  x  x  x  "
" xc    x     "
" x     x    y"
" xxxxxxxxxxxx")

; Round 13
(4
" yyy www yyy "
" ppp ooo ppp "
" bbb ccc bbb "
" rrr ggg rrr "
" ggg rrr ggg "
" ccc bbb ccc "
" ooo ppp ooo "
" www yyy www")

; Round 14
(4
"bbbbbbbbbbbbb"
"x           x"
"bbbbbbbbbbbbb"
"             "
"ossssssssssso"
"x           x"
"wwwwwwwwwwwww"
"             "
"csssssssssssc"
"x           x"
"rrrrrrrrrrrrr"
"             "
"rrrrrrrrrrrrr"
"x           x")

; Round 15
(6
"cwxcccccccxwc"
"cwyxcccccxgwc"
"cwyyxcccxggwc"
"cwyyyxwxgggwc"
"cwyyyywggggwc"
"cwyyyywggggwc"
"cwyyyywggggwc"
"csyyyywggggsc"
"ccsyyywgggscc"
"cccsyywggsccc"
"ccccsywgscccc"
"cccccswsccccc")

; Round 16
(4
"      x      "
"    ww ww    "
"  ww  x  ww  "
"ww  oo oo  ww"
"  oo  x  oo  "
"oo  yy yy  oo"
"  yy  x  yy  "
"yy  gg gg  yy"
"  gg  x  gg  "
"gg  rr rr  gg"
"  rr  x  rr  "
"rr  bb bb  rr"
"  bb     bb  "
"bb         bb")

; Round 17
(4
"      s      "
"   bbbsggg   "
"  bbbwwwggg  "
"  bbwwwwwgg  "
" bbbwwwwwggg "
" bbbwwwwwggg "
" bbbwwwwwggg "
" s  s s s  s "
"      s      "
"      s      "
"      s      "
"    x x      "
"    xxx      "
"     x")

; Round 18
(4
"o xyyyyyyyx o"
"o xxyyyyyxx o"
"o x xyyyx x o"
"o x pxyxc x o"
"o x p s c x o"
"o x p g c x o"
"o x p g c x o"
"o x p g c x o"
"o x p g c x o"
"oxxxp g cxxxo")

; Round 19
(4
"  xxxxxxxxx  "
"  grbpxpbrg  "
"  grbpxpbrg  "
"  grbpxpbrg  "
"  grbpypbrg  "
"  grbpxpbrg  "
"  grbpxpbrg  "
"  grbpxpbrg  "
"  xxxxxxxxx")

; Round 20
(4
"xwxoxcxgxrxbx"
"xpxsxsxsxsxyx"
"             "
"xpx x x x x x"
"x xpx x x x x"
"x x xpx x x x"
"x x x xpx x x"
"x x x x xpx x"
"           p "
"  x x x xpx  "
"  x x xpx x  "
"  x xpx x x  "
"   px x x    "
" p    x")


; Round 21
(4
" xooooooooox "
" x         x "
" x xxxxxxx x "
" x x     x x "
" x x     x x "
" x x rrr x x "
" x x ggg x x "
" x x bbb x x "
" x x www x x "
" x x     x x "
" x xcccccx x "
" x         x "
" x         x "
" xxxxxxxxxxx")

; Round 22
(4
"yyyyyyyyyyyyy"
"yyyyyyyyyyyyy"
"             "
"rrx xrrrx xrr"
"rrx xrrrx xrr"
"rrx xrrrx xrr"
"rrx xrrrx xrr"
"             "
"wwwwwwwwwwwww"
"wwwwwwwwwwwww")

; Round 23
(4
"ccccccccccccc"
"             "
"  sss sss sss"
"  sgs sgs sgs"
"  sss sss sss"
"             "
" sss sss sss "
" srs srs srs "
" sss sss sss "
"             "
"sss sss sss  "
"sbs sbs sbs  "
"sss sss sss")

; Round 24
(7
"     www     "
"     www     "
"     www     "
"    wwwww    "
"    wbwbw    "
"   wbbwbbw   "
"   bbbbbbb   "
"  bbbbbbbbb  "
"  bbbbbbbbb  "
" bbbbbbbbbbb "
"bbbbbbbbbbbbb")

; Round 25
(4
"rrrrrrrrrrrrr"
"ggggggggggggg"
"bbbbbbbbbbbbb"
"xxxxxsssxxxxx"
"xrrrx   xbbbx"
"xrrrx   xbbbx"
"x           x"
"x           x"
"x   xgggx   x"
"x   xgggx   x"
"xsssxxxxxsssx")

; Round 26
(4
"  xsssx      "
" x     x     "
"x  ccc  x    "
"x ggggg x    "
"x bbbbb x    "
"x  ppp  x    "
" x     x     "
"  xxxxx")

; Round 27
(11
"sssssssssssss"
"yyyyyyyyyyyyy"
"sssssssssssss"
"             "
"sssssssssssss"
"rrrrrrrrrrrrr"
"sssssssssssss")

; Round 28
(3
"bbbbbbbbbbbbb"
"bxxxxpxpxxxxb"
"bx         xb"
"bxp       pxb"
"bxpp     ppxb"
"bxppp   pppxb"
" bxppp pppxb "
"  bxpppppxb  "
"   bxpppxb   "
"    bxpxb    "
"     bpb     "
"      b")

; Round 29
(4
"yyyyyx xyyyyy"
"pppppx xppppp"
"xxwxxx xxxwxx"
"bbbbbx xbbbbb"
"rrrrrx xrrrrr"
"gggggx xggggg"
"sswssx xsswss"
"cccccx xccccc"
"ooooox xooooo"
"wwwwwx xwwwww")

; Round 30
(4
"yp           "
"ypbr         "
"ypbrgc       "
"ypbrgcow     "
"ypbrgcowyp   "
"spbrgcowypbr "
" xsrgcowypbrg"
"   xscowypbrg"
"     xswypbrg"
"       xspbrg"
"         xsrg"
"           xs")

; Round 31
(4
"g r b p y w o"
"s s s s s s s"
" b r g c o w "
" s s s s s s "
"c g r b p y w"
"s s s s s s s"
" p b r g c o "
" s s s s s s "
"o c g r b p y"
"s s s s s s s"
" y p b r g c "
" s s s s s s "
"w o c g r b p"
"s s s s s s s")

; Round 32
(4
"  x x x x x  "
"  x x x x x  "
"  x x x xgg  "
"  x x x x x  "
"  x x xrrrr  "
"  x x x x x  "
"  x xbbbbbb  "
"  x x x x x  "
"  xpppppppp  "
"  x x x x x  "
"  yyyyyyyyy  "
"  sssssssss")

; Round 33: Unused round 33 that is in the original ROMs but never used.
; Not yet actived in Arukanoido.
(5
"   pp   pp   "
"  pppp pppp  "
"  pppp pppp  "
" ppppssppppp "
" ppppssppppp "
" pppppsspppp "
" pppppsspppp "
"  pppsspppp  "
"  pppsspppp  "
"   pppsspp   "
"   pppsspp   "
"    psspp    "
"     ssp     "
"      s")
))))

(fn get-brick (x)
  (position x *bricks*))

(const +level-data+ (with-queue q
                      (dolist (level *levels* (queue-list q))
                        (enqueue q level.) ; Y offset of bricks.
                        (dolist (line .level)
                          (dolist (brick (string-list line))
                            (enqueue q (get-brick brick))))
                        (enqueue q 15))))

(fn check-zeropage-size (x)
  (? (< x *pc*)
     (error "Address ~A overflown by ~A bytes." x (abs (- *pc* x)))
     (format t "~A bytes free until address ~A.~%" (- x *pc*) x)))

(const +degrees+ 256)
(const smax 127)

(fn negate (x)
  (@ [- _] x))

(fn full-sin-wave (x)
  (+ x
     (reverse x)
     (negate x)
     (reverse (negate x))))

(fn full-cos-wave (x)
  (+ x
     (reverse (negate x))
     (negate x)
     (reverse x)))

(define-filter bytes #'byte)

(fn ball-directions-x ()
  (let m (/ 360 +degrees+)
    (bytes (maptimes [integer (* smax (degree-sin (* m _)) 0.5)] +degrees+))))

(fn ball-directions-y ()
  (let m (/ 360 +degrees+)
    (bytes (maptimes [integer (* smax (degree-cos (* m _)))] +degrees+))))

(fn make (to files cmds)
  (apply #'assemble-files to files)
  (make-vice-commands cmds "break .stop"))

(fn make-game (version file cmds)
  (make file
        (@ [+ "src/" _] `("../bender/vic-20/vic.asm"
                          "constants.asm"
                          "zeropage.asm"
                          ,@(unless (| *shadowvic?*
                                       *rom?*)
                              '("../bender/vic-20/basic-loader.asm"))
                          ,@(unless *rom?*
                              '("init.asm"
                                "gap.asm"))
                          ,@(when *rom?*
                              '("init-rom.asm"))

                          ; Imported music player binary.
                          "music-player.asm"

                          ; Graphics
                          "font-4x8.asm"
                          "gfx-background.asm"
                          "gfx-doh.asm"
                          "gfx-explosion.asm"
                          "gfx-obstacle-cone.asm"
                          "gfx-obstacle-cube.asm"
                          "gfx-obstacle-pyramid.asm"
                          "gfx-obstacle-spheres.asm"
                          "gfx-sprites.asm"
                          "gfx-ship.asm"
                          "gfx-taito.asm"

                          ; Level data
                          "level-data.asm"

                          ; Tables
                          "bits.asm"
                          "paddle-xlat.asm"
                          "ball-directions.asm"
                          "score-infos.asm"
                          "brick-info.asm"
                          "sprite-inits.asm"

                          ; VCPU
                          "vcpu.asm"
                          "vcpu-instructions.asm"
                          "_vcpu.asm"

                          ; Library
                          "audio-boost.asm"
                          "bcd.asm"
                          ,@(unless *rom?*
                              '("blitter.asm"
                                "exm-nmi.asm"))
                          "chars.asm"
                          "digisound.asm"
                          "draw-bitmap.asm"
                          "exomizer-stream-decrunsh.asm"
                          "exm-player.asm"
                          "joystick.asm"
                          "keyboard.asm"
                          "math.asm"
                          "music.asm"
                          "screen.asm"
                          "random.asm"
                          "print.asm"
                          "sprites.asm"
                          "sprites-vic-common.asm"
                          "sprites-vic.asm"
                          "sprites-vic-huge.asm"
                          "wait.asm"

                          ; Level display
                          "brick-fx.asm"
                          "draw-level.asm"
                          "lifes.asm"
                          "score-display.asm"

                          ; Display object interactions
                          "get-collision.asm"
                          "hit-brick.asm"
                          "reflect.asm"
                          "reflect-edge.asm"
                          "reflect-ball-obstacle.asm"
                          "score.asm"

                          ; Sprite controllers
                          "step-arcade.asm"
                          "step-smooth.asm"
                          "ctrl-ball.asm"
                          "ctrl-bonus.asm"
                          "ctrl-explosion.asm"
                          "ctrl-laser.asm"
                          "ctrl-obstacle.asm"
                          "ctrl-vaus.asm"
                          "doh.asm"

                          ; Top level
                          ,@(when *debug?*
                              '("debug.asm"))
                          "irq.asm"
                          "format.asm"
                          "game.asm"
                          "hiscore.asm"
                          "main.asm"
                          "round-intro.asm"
                          "round-start.asm"
                          "patch.asm"

                          ; Add-ons
                          "music-arcade.asm"

                          ,@(when *rom?*
                              '("init.asm"
                                "moveram.asm"
                                "lowmem-start.asm"
                                "blitter.asm"
                                "exm-nmi.asm"
                                "lowmem-end.asm"))

                          "end.asm"))
        cmds)
  (!= (- #x314 (get-label 'before_int_vectors))
    (format t "~A bytes free before interrupt vectors.~%" !)
    (? (< ! 0)
       (quit)))
  (!= (- #x8000 (get-label 'the_end))
    (format t "~A bytes free.~%" !)))

(fn paddle-xlat ()
  (maptimes [bit-and (integer (+ 8 (/ (- 255 _) ; TODO: Häh?
                                      (/ 256 (++ (* 8 12))))))
                     #xfe] 256))

(= *model* :vic-20+xk)

(apply #'assemble-files "obj/gfx-ship.bin" '("media/gfx-ship.asm"))
(exomize-stream "obj/gfx-ship.bin" "obj/gfx-ship.bin.exo")
(apply #'assemble-files "obj/gfx-taito.bin" '("media/gfx-taito.asm"))
(exomize-stream "obj/gfx-taito.bin" "obj/gfx-taito.bin.exo")
(apply #'assemble-files "obj/gfx-background.bin" '("media/gfx-background.asm"))
(exomize-stream "obj/gfx-background.bin" "obj/gfx-background.bin.exo")
(put-file "obj/levels.bin" (list-string (@ #'code-char +level-data+)))
(exomize-stream "obj/levels.bin" "obj/levels.bin.exo")

(fn packed-font ()
  (assemble-files "obj/font-4x8.bin" "media/font-4x8.asm")
  (mapcan [maptimes #'((i)
                                 (!= (? (== (length _) 16)
                                        _
                                        (+ _ (maptimes [identity 0] 8)))
                                   (+ (elt ! i) (<< (elt ! (+ i 8)) 4))))
                    8]
          (group (filter #'char-code (string-list (fetch-file "obj/font-4x8.bin"))) 16)))

(put-file "obj/font-4x8-packed.bin" (list-string (@ #'code-char (packed-font))))

(gen-vcpu-tables "src/_vcpu.asm")
;(with-temporary *shadowvic?* t
;  (make-game :prg "arukanoido-shadowvic.bin" "arukanoido-shadowvic.vice.txt"))
(with-temporary *show-cpu?* t
  (make-game :prg "arukanoido-cpumon.prg" "arukanoido-cpumon.vice.txt"))
(with-temporary *rom?* t
  (make-game :prg "arukanoido.img" "arukanoido.img.vice.txt")
  (!= (- #x3ce (+ (get-label 'lowmem) (get-label 'lowmem_size)))
    (format t "~A bytes till $3ce.~%" !)
    (? (< ! 0)
       (quit))))
(make-game :prg "arukanoido.prg" "arukanoido.prg.vice.txt")

(format t "Level data: ~A B~%" (length +level-data+))

(unix-sh-mkdir "arukanoido")
(@ (i '("arukanoido.prg"
        "arukanoido-cpumon.prg"))
  (sb-ext:run-program "/usr/local/bin/exomizer" (list "sfx" "basic" "-B" "-t52" "-x1" "-o" (+ "arukanoido/" i) i)
                      :pty cl:*standard-output*))

(sb-ext:run-program "/usr/bin/split" (list "-b" "8192" "arukanoido.img" "arukanoido/arukanoido.img.")
                    :pty cl:*standard-output*)
(sb-ext:run-program "/bin/cp" (list "README.md" "arukanoido/")
                    :pty cl:*standard-output*)

(quit)
