(load "gen-vcpu-tables.lisp")
(= *model* :vic-20+xk)

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

(fn exomize-stream (from to)
  (sb-ext:run-program "/usr/local/bin/exomizer" (list "raw" "-B" "-m" "256" "-M" "256" "-o" to from)
                      :pty cl:*standard-output*))

(load "build/level-data.lisp")
(load "build/audio.lisp")
(load "prg-launcher/make.lisp")

(fn packed-font ()
  (assemble-files "obj/font-4x8.bin" "media/font-4x8.asm")
  (mapcan [maptimes #'((i)
                                 (!= (? (== (length _) 16)
                                        _
                                        (+ _ (maptimes [identity 0] 8)))
                                   (+ (elt ! i) (<< (elt ! (+ i 8)) 4))))
                    8]
          (group (filter #'char-code (string-list (fetch-file "obj/font-4x8.bin"))) 16)))

(fn ascii2pixcii (x)
  (@ [?
       (== 32 (char-code _))  (code-char 255)
       (alpha-char? _)        (code-char (+ (- (char-code _) (char-code #\A)) (get-label 'framechars)))
       _]
     (string-list x)))

(fn string4x8 (x)
  (@ [- (char-code _) 32] (string-list x)))

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
                          "chars.asm"
                          "exomizer-stream-decrunsh.asm"
                          "joystick.asm"
                          "keyboard.asm"
                          "math.asm"
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

                          ; Level data
                          "level-data.asm"

                          "draw-bitmap.asm"
                          "gfx-taito.asm"

                          "gfx-ship.asm"
                          "round-intro.asm"
                          "round-start.asm"

                          ; Digital audio
                          ,@(unless *rom?*
                              '("exm-nmi.asm"))
                          "audio-boost.asm"
                          "digisound.asm"
                          "exm-player.asm"
                          "raw-player.asm"
                          "rle-player.asm"

                          "music-arcade.asm"

                          ,@(when *rom?*
                              '("init.asm"
                                "patch.asm"
                                "moveram.asm"
                                "music-arcade-blk5.asm"
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

(fn make-prg (file)
  (make "obj/music-arcade-blk5.bin"
        `("prg-launcher/blk5.asm"
          "src/music-arcade-blk5.asm")
        "obj/music-arcade-blk5.vice.lst")
  (with-temporary *imported-labels* (get-labels)
    (make-game (+ "obj/" file ".prg") (+ "obj/" file ".prg.vice.txt")))
  (sb-ext:run-program "/usr/local/bin/exomizer"
                      (list "sfx" "basic" "-B" "-t52" "-o" (+ "obj/" file ".exo.prg") (+ "obj/" file ".prg"))
                      :pty cl:*standard-output*))

(unix-sh-mkdir "obj")
(unix-sh-mkdir "arukanoido")

(when *all?*
  (put-file "obj/title.bin" (minigrafik-without-code "media/ark-title.prg"))
  (exomize-stream "obj/title.bin" "obj/title.bin.exo")
  (apply #'assemble-files "obj/gfx-ship.bin" '("media/gfx-ship.asm"))
  (exomize-stream "obj/gfx-ship.bin" "obj/gfx-ship.bin.exo")
  (apply #'assemble-files "obj/gfx-taito.bin" '("media/gfx-taito.asm"))
  (exomize-stream "obj/gfx-taito.bin" "obj/gfx-taito.bin.exo")
  (apply #'assemble-files "obj/gfx-background.bin" '("media/gfx-background.asm"))
  (exomize-stream "obj/gfx-background.bin" "obj/gfx-background.bin.exo")
  (put-file "obj/levels.bin" (list-string (@ #'code-char +level-data+)))
  (exomize-stream "obj/levels.bin" "obj/levels.bin.exo")

  (put-file "obj/font-4x8-packed.bin" (list-string (@ #'code-char (packed-font))))

  (make-arcade-sounds)
  (gen-vcpu-tables "src/_vcpu.asm"))

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

(when *all?*
  (make-cart)
  (with-temporary *tape?* t
    (make-prg "arukanoido-tape"))

  (with-temporary *show-cpu?* t
    (make-prg "arukanoido-cpumon"))
  ;(with-temporary *shadowvic?* t
  ;  (make-game "arukanoido-shadowvic.bin" "arukanoido-shadowvic.vice.txt"))
  )

(make-prg "arukanoido")
(make-prg-launcher)

(unix-sh-cp "obj/arukanoido.prg" "arukanoido/")

(format t "Level data: ~A B~%" (length +level-data+))

(sb-ext:run-program "/bin/cp"
                    (list "README.md" "NEWS" "arukanoido/")
                    :pty cl:*standard-output*)

(quit)
