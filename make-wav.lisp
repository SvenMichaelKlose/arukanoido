(load "c2nwarp/make.lisp")

(with-input-file i "arukanoido/arukanoido.tap" (with-output-file o "arukanoido/arukanoido.pal.wav" (tap2wav i o 44100 (cpu-cycles :pal))))
;(with-input-file i "arukanoido/arukanoido.tap" (with-output-file o "arukanoido/arukanoido.ntsc.wav" (tap2wav i o 44100 (cpu-cycles :ntsc))))

(sb-ext:run-program "/usr/bin/zip" (list "-r" "-9" "arukanoido.zip" "arukanoido")
                    :pty cl:*standard-output*)
(quit)
