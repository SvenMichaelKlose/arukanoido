(load "gen-vcpu-tables.lisp")

(= *model* :vic-20+xk)
(var *audio-rate* 4000)
(var *audio-rate-fast* 5000)
(var *audio-rate-expanded* 6000)
(var *revision* (!= (fetch-file "_revision")
                  (subseq ! 0 (-- (length !)))))

(var *demo?* nil)       ; Limit to first eight levels.
(var *rom?* nil)
(var *tape?* t)         ; Make TAP.
(var *wav?* nil)          ; Also make WAV.
(var *has-digis?* t)    ; Original arcade sounds, highly compressed
                        ; with exomizer or home-made RLE.
(var *debug?* nil)
(var *shadowvic?* nil)
(var *ultimem?* nil)    ; Add support for high-end arcade audio
                        ; (from tape or SD only).
(var *make-arcade-sounds?* nil) ; Lengthy process.
(var *all?* nil)        ; *rom*, *tape*, *shadowvic?*

(var *add-charset-base?* t) ; TODO: Hard code it.
(var *show-cpu?* nil)       ; Border effects by sprite engine.


(when *all?*
  (= *rom* t
     *tape* t
     *shadowvic?* t))

(load "build/audio.lisp")
(load "build/font.lisp")
(load "build/level-data.lisp")
(load "media/make.lisp")
(load "prg-launcher/make.lisp")
(load "c2nwarp/make.lisp")

(fn exomize-stream (from to)
  (sb-ext:run-program "/usr/local/bin/exomizer-2.0.10" (list "raw" "-B" "-m" "256" "-M" "256" "-o" to from)
                      :pty cl:*standard-output*))

(fn gen-sprite-nchars ()
  (with-queue q
    (dotimes (a 8)
      (dotimes (b 8)
        (enqueue q (* a b))))
    (queue-list q)))

(fn make-reverse-patch-id ()
  (string4x8 (list-string (reverse (string-list "ARUKANOIDO PATCH")))))

(fn check-zeropage-size (x)
  (? (< x *pc*)
     (error "Address ~A overflown by ~A bytes." x (abs (- *pc* x)))
     (format t "~A bytes free until address ~A.~%" (- x *pc*) x)))

(fn ball-directions-y ()
  (let m (/ 360 256)
    (@ #'byte (maptimes [integer (* 127 (degree-cos (* m _)))] 256))))

(fn paddle-xlat ()
  (maptimes [bit-and (integer (+ 8 (/ (- 255 _) ; TODO: Häh?
                                      (/ 256 (++ (* 8 12))))))
                     #xfe] 256))

(fn make (to files cmds)
  (apply #'assemble-files to files)
  (make-vice-commands cmds (format nil "break .stop~%break .stop2~%break .stop3")))

(fn make-game (file cmds)
  (make file
        (@ [+ "src/" _] `("../bender/vic-20/vic.asm"
                          "constants.asm"
                          "zeropage.asm"

                          ,@(unless (| *shadowvic?* *rom?*)
                              '("../bender/vic-20/basic-loader.asm"))
                          ,@(? *rom?*
                              '("init-rom.asm")
                              '("init.asm"
                                "patch.asm"
                                "gap.asm"))

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
                          "gfx-taito.asm"
                          "gfx-ship.asm"

                          ; Mixed data
                          "bits.asm"
                          "paddle-xlat.asm"
                          "ball-directions.asm"
                          "score-infos.asm"
                          "brick-info.asm"
                          "sprite-inits.asm"
                          "level-data.asm"

                          ; Virtual CPU
                          "vcpu.asm"
                          "vcpu-instructions.asm"
                          "_vcpu.asm"

                          ; Library
                          "bcd.asm"
                          "clrram.asm"
                          "exomizer-stream-decrunsh.asm"
                          "joystick.asm"
                          "keyboard.asm"
                          "math.asm"
                          "random.asm"
                          "wait.asm"
                          "zeropage-utils.asm"

                          ; Graphics library
                          "print.asm"
                          "format.asm"
                          "chars.asm"
                          "screen.asm"
                          "draw-bitmap.asm"

                          ; Sprites
                          ,@(unless *rom?*
                              '("blitter.asm"))
                          "blit-char.asm"
                          "sprites.asm"
                          "sprites-vic-common.asm"
;                          "sprites-vic.asm"
                          "sprites-vic-huge.asm"
                          "sprites-vic-huge-preshifted.asm"

                          ; Digital audio
                          ,@(when *has-digis?*
                              `(,@(unless *rom?*
                                    '("exm-nmi.asm"))
                                "audio-boost.asm"
                                "digi-nmi.asm"
                                "exm-player.asm"
                                ,@(when *ultimem?*
                                    '("raw-player.asm"))
                                "rle-player.asm"
                                "music-arcade.asm"))

                          ; Level display
                          "brick-fx.asm"
                          "draw-level.asm"
                          "lifes.asm"
                          "score-display.asm"

                          ; Collisions
                          "get-collision.asm"
                          "hit-brick.asm"
                          "reflect.asm"
                          "reflect-edge.asm"
                          "reflect-ball-obstacle.asm"
                          "score.asm"

                          ; Sprite controllers
                          "step-smooth.asm"
                          "ctrl-ball.asm"
                          "ctrl-bonus.asm"
                          "ctrl-explosion.asm"
                          "ctrl-laser.asm"
                          "ctrl-obstacle.asm"
                          "ctrl-doh-obstacle.asm"
                          "ctrl-vaus.asm"
                          "doh.asm"

                          ; Music
                          "music-index.asm"
                          "music.asm"

                          ; Top-level
                          ,@(when *debug?*
                              '("debug.asm"))
                          "irq.asm"
                          "game.asm"
                          "main.asm"
                          "round-start.asm"
                          "hiscore.asm"
                          "round-intro.asm"

                          ,@(when *rom?*
                              `("init.asm"
                                "patch.asm"
                                "moveram.asm"
                                ,@(when *has-digis?*
                                    `("music-arcade-blk5.asm"
                                      "blk5-end.asm"))

                                "lowmem-start.asm"
                                "blitter.asm"
                                ,@(when *has-digis?*
                                    `("exm-nmi.asm"))
                                "lowmem-end.asm"))

                          "end.asm"))
        cmds)
  (format t "Level data (uncompressed): ~A B~%" (length +level-data+))
  (format t "Game end: ~X~%" (get-label '__end_game))
  (format t "Round start end: ~X~%" (get-label '__end_round_start))
  (format t "Round start size: ~A~%" (- (get-label '__end_round_start) (get-label '__end_game)))
  (format t "Hiscore size: ~A~%" (- (get-label '__end_hiscore) (get-label '__end_round_start)))
  (format t "Round intro end: ~X~%" (get-label '__end_round_intro))
  (format t "Round intro size: ~A~%" (- (get-label '__end_round_intro) (get-label '__end_hiscore)))
  (format t "~A zero page bytes free.~%" (- #x00fc (get-label 'zp_end)))
  (format t "~A bytes free before interrupt vectors.~%" (- #x314 (get-label 'before_int_vectors)))
  (format t "~A low memory bytes free.~%" (- #x0400 (get-label 'lowmem)))
  (!= (- #x8000 (get-label 'the_end))
    (format t "~A bytes free before $8000.~%" !))
  (when *has-digis?*
    (!= (- #xc000 (get-label 'blk5_end))
      (format t "~A bytes free before $c000.~%" !))))

(fn make-prg (file)
  (when *has-digis?*
    (make "obj/music-arcade-blk5.bin"
          `("prg-launcher/blk5.asm"
            "src/music-arcade-blk5.asm"
            "src/blk5-end.asm")
          "obj/music-arcade-blk5.bin.lbl"))
  (with-temporary *imported-labels* (get-labels)
    (make-game (+ "obj/" file ".prg") (+ "obj/" file ".prg.lbl")))
  (unless *shadowvic?*
    (sb-ext:run-program "/usr/local/bin/exomizer-2.0.10"
                        (list "sfx" "basic" "-t52" "-o" (+ "obj/" file ".exo.prg") (+ "obj/" file ".prg"))
                        :pty cl:*standard-output*)))

(fn make-rom ()
  (with-temporary *rom?* t
    (make-game "obj/arukanoido.img" "obj/arukanoido.img.lbl")
    (!= (- #x3ce (+ (get-label 'lowmem) (get-label 'lowmem_size)))
      (format t "~A bytes till $3ce.~%" !)
      (? (< ! 0)
         (quit)))
    (!= (- #xc000 (get-label 'the_end))
      (format t "~A bytes till $c000.~%" !)))
  (sb-ext:run-program "/usr/bin/split"
                      (list "-b" "8192" "obj/arukanoido.img" "arukanoido/arukanoido.img.")
                      :pty cl:*standard-output*))

(fn make-tap ()
  (apply #'assemble-files
         "obj/tape-loader.prg"
         `("src/music-index.asm"
           "loader/zeropage.asm"
           "bender/vic-20/basic-loader.asm"
           "loader/main.asm"
           "bender/vic-20/minigrafik-display.asm"
           "loader/exomizer-stream-decrunsh.asm"
           "loader/audio.asm"
           "loader/loader.asm"
           "loader/ctrl.asm"))
  (make-vice-commands "obj/tape-loader.prg.lbl" "break .stop")
  (format t "Short pulse: ~A~%" *pulse-short*)
  (format t "Long pulse: ~A~%" *pulse-long*)
  (format t "Pulse interval: ~A~%" *pulse-interval*)
  (format t "Pulse subinterval: ~A~%" (/ *pulse-interval* 4))
  (format t "Pulse rate PAL: ~A~%" (integer (/ (cpu-cycles :pal) *tape-pulse*)))
  (format t "C2NWARP rate PAL: ~A~%" (integer (* 2 (/ (cpu-cycles :pal) *tape-pulse*))))
  (format t "Pulse rate NTSC: ~A~%" (integer (/ (cpu-cycles :ntsc) *tape-pulse*)))
  (format t "C2NWARP rate NTSC: ~A~%" (integer (* 2 (/ (cpu-cycles :ntsc) *tape-pulse*))))
  (with-output-file o "arukanoido/arukanoido.tap"
    (write-tap o
               (+ (bin2cbmtap (cddr (string-list (fetch-file "obj/tape-loader.prg")))
                              "ARUKANOIDO"
                              :start #x1201
                              :no-gaps? t)
                  (with-input-file i "obj/title.bin.exo"
                    (format t "Appending title screen…~%")
                    (with-string-stream s (c2ntap s i)))
                  (with-input-file i "obj/arukanoido-tape.exo.prg"
                    (format t "Appending executable…~%")
                    (with-string-stream s (c2ntap s i)))
                  (with-input-file i "obj/music-arcade-blk5.bin"
                    (format t "Appending BLK5…~%")
                    (with-string-stream s (c2ntap s i)))
                  (when *ultimem?*
                    (format t "Appending Ultimem arcade audio…~%")
                    (apply #'+
                           (@ [(format t "Appending \"~A\"…~%" _)
                               (let l (length (fetch-file (+ "obj-audio/" _ ".1.8000.raw")))
                                 (with-stream-string i (+ (string (code-char (mod l 256)))
                                                          (string (code-char (mod (>> l 8) 256)))
                                                          (string (code-char (>> l 16)))
                                                          (fetch-file (+ "obj-audio/" _ ".1.8000.exm")))
                                    (with-string-stream s (c2ntap s i :sync? nil :gap #x4000000))))]
                              '("break-out"
                                "explosion"
                                "extension"
                                "extra-life"
                                "game-over"
                                "laser"
                                "lost-ball"
                                "reflection-doh"
                                "reflection-high"
                                "reflection-med"
                                "reflection-low"
                                "round-intro"
                                "round-start"
                                "doh-dissolving"
                                "doh-intro"
                                "final"))))))))

(unix-sh-mkdir "obj")
(unix-sh-mkdir "obj-audio")
(unix-sh-mkdir "arukanoido")

(gen-vcpu-tables "src/_vcpu.asm")
(make-font)
(make-level-data)
(make-media)

(make-prg "arukanoido-disk")
(? *has-digis?*
   (progn
     (make-prg-launcher)
     (unix-sh-cp "obj/arukanoido.prg" "arukanoido/"))
   (unix-sh-cp "obj/arukanoido-disk.exo.prg" "arukanoido/arukanoido.prg"))

(when *make-arcade-sounds?*
  (make-arcade-sounds))
(when *rom?*
  (make-rom))
(when *tape?*
  (make-prg "arukanoido-tape")
  (make-tap))
(when *shadowvic?*
  (with-temporary *has-digis?* nil
    (make-prg "arukanoido-shadowvic")))
;(unix-sh-cp "arukanoido-cpumon.prg" "arukanoido/arukanoido-cpumon.prg")
(when (& *tape?* *wav?*)
  (with-input-file i "arukanoido/arukanoido.tap"
    (with-output-file o "arukanoido/arukanoido.wav"
      (tap2wav i o 44100 (cpu-cycles :ntsc)))))
(sb-ext:run-program "/bin/cp"
                    (list "README.md" "NEWS" "arukanoido/")
                    :pty cl:*standard-output*)

(sb-ext:run-program "/usr/bin/zip" (list "-r" "-9" "arukanoido.zip" "arukanoido")
                    :pty cl:*standard-output*)
(sb-ext:run-program "/bin/cp" (list "arukanoido.zip"
                                    (+ "arukanoido."
                                       (? *demo?* "demo." "")
                                       *revision* ".zip"))
                    :pty cl:*standard-output*)

(quit)
