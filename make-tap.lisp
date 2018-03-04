(load "c2nwarp/make.lisp")

(fn assemble-loader ()
  (apply #'assemble-files "c2nwarp.prg"
         `("src/music-index.asm"
           "loader/zeropage.asm"
           "bender/vic-20/basic-loader.asm"
           "loader/main.asm"
           "bender/vic-20/minigrafik-display.asm"
           "loader/exomizer-stream-decrunsh.asm"
           "loader/audio.asm"
           "loader/loader.asm"
           "loader/ctrl.asm"))
  (make-vice-commands "loader.vice.txt" "break .stop")
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
               (+ (bin2cbmtap (cddr (string-list (fetch-file "c2nwarp.prg")))
                              "ARUKANOIDO"
                              :start #x1201
                              :short-data? t
                              :no-gaps? t)
                  (with-input-file i "obj/title.bin.exo"
                    (with-string-stream s (c2ntap s i)))
                  (list-string (@ #'code-char '(0 0 0 8)))
                  (with-input-file i "obj/arukanoido-tape.exo.prg"
                    (with-string-stream s (c2ntap s i :sync? nil)))
                  (with-input-file i "obj/music-arcade-blk5.bin"
                    (with-string-stream s (c2ntap s i :sync? nil)))
                  (apply #'+ (@ [let l (length (fetch-file (+ "obj/" _ ".1.6000.raw")))
                                  (with-stream-string i (+ (string (code-char (mod l 256)))
                                                           (string (code-char (mod (>> l 8) 256)))
                                                           (string (code-char (>> l 16)))
                                                           (fetch-file (+ "obj/" _ ".1.6000.exm")))
                                    (with-string-stream s (c2ntap s i :sync? nil :gap #x6000000)))]
                                '("break-out"
                                  "explosion" "extension"
                                  "extra-life" "game-over" "laser" "lost-ball" "reflection-doh"
                                  "reflection-high" "reflection-med" "reflection-low"
                                  "round-intro" "round-start"
                                  "doh-dissolving" "doh-intro"
                                  "final")))))))


(assemble-loader)

(quit)
