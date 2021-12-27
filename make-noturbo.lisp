(fn assemble-loader ()
  (with-output-file o "arukanoido/arukanoido-noturbo.tap"
    (write-tap o
               (bin2cbmtap (cddr (string-list (fetch-file "arukanoido/arukanoido.prg")))
                              "ARUKANOIDO"
                              :start #x1201
                              :no-gaps? nil))))

(assemble-loader)

(with-input-file i "arukanoido/arukanoido-noturbo.tap" (with-output-file o "arukanoido/arukanoido-noturbo.wav" (tap2wav i o 44100 (cpu-cycles :pal))))
(quit)
