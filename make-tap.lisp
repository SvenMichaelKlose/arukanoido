(load "c2nwarp/make.lisp")

(fn assemble-loader (&key title path-in path-out (start #x1201))
  (apply #'assemble-files "c2nwarp.prg"
         `("loader/zeropage.asm"
           "bender/vic-20/basic-loader.asm"
           "loader/main.asm"
           "bender/vic-20/minigrafik-display.asm"
           "src/exomizer-stream-decrunsh.asm"
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
  (with-output-file o path-out
    (write-tap o
               (+ (bin2cbmtap (cddr (string-list (fetch-file "c2nwarp.prg")))
                              title
                              :start start
                              :short-data? t
                              :no-gaps? t)
                  (with-input-file i "obj/title.bin.exo"
                    (with-string-stream s (c2ntap s i)))
                  (list-string (@ #'code-char '(0 0 0 8)))
                  (with-input-file i path-in
                    (with-string-stream s (c2ntap s i :sync? nil)))
                  (with-input-file i "obj/music-expanded.bin"
                    (with-string-stream s (c2ntap s i :sync? nil)))))))

(with-temporary *path-main* "arukanoido/arukanoido.prg"
  (assemble-loader :title "ARUKANOIDO"
                   :path-in "arukanoido/arukanoido.prg"
                   :path-out "arukanoido/arukanoido.tap"))

(quit)
