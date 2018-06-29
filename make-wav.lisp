(load "c2nwarp/make.lisp")

(var *revision* (!= (fetch-file "_revision")
                  (subseq ! 0 (-- (length !)))))

(with-input-file i "arukanoido/arukanoido.tap" (with-output-file o "arukanoido/arukanoido.wav" (tap2wav i o 44100 (cpu-cycles :ntsc))))

(sb-ext:run-program "/usr/bin/zip" (list "-r" "-9" "arukanoido.zip" "arukanoido")
                    :pty cl:*standard-output*)
(sb-ext:run-program "/bin/cp" (list "arukanoido.zip" (+ "arukanoido." *revision* ".zip"))
                    :pty cl:*standard-output*)
(quit)
