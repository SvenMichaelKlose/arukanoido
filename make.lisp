(load "gen-vcpu-tables.lisp")
(= *model* :vic-20+xk)

(var *audio-rate* 4000)
(var *audio-rate-fast* 5000)
(var *audio-rate-expanded* 6000)

(var *demo?* nil)
(var *all?* t)
(var *add-charset-base?* t)
(var *debug?* nil)
(var *revision* (!= (fetch-file "_revision")
                  (subseq ! 0 (-- (length !)))))

(var *rom?* nil)
(var *tape?* nil)
(var *shadowvic?* nil)
(var *show-cpu?* nil)
(var *has-digis?* nil)

(fn exomize-stream (from to)
  (sb-ext:run-program "/usr/local/bin/exomizer" (list "raw" "-m" "256" "-M" "256" "-o" to from)
                      :pty cl:*standard-output*))

(load "build/audio.lisp")
(load "build/font.lisp")
(load "build/level-data.lisp")
(load "media/make.lisp")
(load "prg-launcher/make.lisp")

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
                          ,@(unless (| *shadowvic?*
                                       *rom?*)
                              '("../bender/vic-20/basic-loader.asm"))
                          ,@(unless *rom?*
                              '("init.asm"
                                "patch.asm"
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
                          "bcd.asm"
                          ,@(unless *rom?*
                              '("blitter.asm"))
                          "blit-char.asm"
                          "chars.asm"
                          "exomizer-stream-decrunsh.asm"
                          "joystick.asm"
                          "keyboard.asm"
                          "math.asm"
                          "music-index.asm"
                          "music.asm"
                          "screen.asm"
                          "random.asm"
                          "print.asm"
                          "sprites.asm"
                          "sprites-vic-common.asm"
;                          "sprites-vic.asm"
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

                          ; Level data
                          "level-data.asm"

                          "draw-bitmap.asm"
                          "gfx-taito.asm"

                          "gfx-ship.asm"
                          "round-intro.asm"
                          "round-start.asm"

                          ; Digital audio
                          ,@(when *has-digis?*
                              `(,@(unless *rom?*
                                    '("exm-nmi.asm"))
                                "audio-boost.asm"
                                "digi-nmi.asm"
                                "exm-player.asm"
                                "raw-player.asm"
                                "rle-player.asm"
                                "music-arcade.asm"))

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
  (!= (- #x314 (get-label 'before_int_vectors))
    (format t "~A bytes free before interrupt vectors.~%" !)
    (? (< ! 0)
       (quit)))
  (!= (- #x8000 (get-label 'the_end))
    (format t "~A bytes free before $a000.~%" !))
  (when *has-digis?*
    (!= (- #xc000 (get-label 'blk5_end))
      (format t "~A bytes free before $C000.~%" !))))

(fn make-prg (file)
  (when *has-digis?*
    (make "obj/music-arcade-blk5.bin"
          `("prg-launcher/blk5.asm"
            "src/music-arcade-blk5.asm"
            "src/blk5-end.asm")
          "obj/music-arcade-blk5.vice.lst"))
  (with-temporary *imported-labels* (get-labels)
    (make-game (+ "obj/" file ".prg") (+ "obj/" file ".prg.vice.txt")))
  (unless *shadowvic?*
    (sb-ext:run-program "/usr/local/bin/exomizer"
                        (list "sfx" "basic" "-t52" "-o" (+ "obj/" file ".exo.prg") (+ "obj/" file ".prg"))
                        :pty cl:*standard-output*)))

(fn make-cart ()
  (with-temporary *rom?* t
    (make-game "arukanoido.img" "obj/arukanoido.img.vice.txt")
    (!= (- #x3ce (+ (get-label 'lowmem) (get-label 'lowmem_size)))
      (format t "~A bytes till $3ce.~%" !)
      (? (< ! 0)
         (quit)))
    (!= (- #xc000 (get-label 'the_end))
      (format t "~A bytes till $c000.~%" !)))
  (sb-ext:run-program "/usr/bin/split"
                      (list "-b" "8192" "arukanoido.img" "arukanoido/arukanoido.img.")
                      :pty cl:*standard-output*))

(fn make-zip ()
  (unix-sh-cp "obj/arukanoido.exo.prg" "arukanoido/arukanoido.prg")
  (unix-sh-cp "arukanoido-cpumon.prg" "arukanoido/arukanoido-cpumon.prg")
  (sb-ext:run-program "/bin/cp"
                      (list "README.md" "NEWS" "arukanoido/")
                      :pty cl:*standard-output*))

(unix-sh-mkdir "obj")
(unix-sh-mkdir "arukanoido")

(gen-vcpu-tables "src/_vcpu.asm")
(make-font)
(make-level-data)
(make-media)

(when *all?*
  (when *has-digis?*
    (make-arcade-sounds))
  (make-cart)
  (with-temporary *tape?* t
    (make-prg "arukanoido-tape"))
  (with-temporary *show-cpu?* t
    (make-prg "arukanoido-cpumon")
    (make-prg-launcher))
  (with-temporary *shadowvic?* t
    (with-temporary *has-digis?* nil
      (make-prg "arukanoido-shadowvic")
      (unix-sh-cp "obj/arukanoido-shadowvic.prg" "."))))

(make-prg "arukanoido")
(make-prg-launcher)

(when *all?*
  (make-zip))

(format t "Level data: ~A B~%" (length +level-data+))

(quit)
