(load "c2nwarp/make.lisp")

(with-temporary *path-main* "arukanoido/arukanoido.pal.prg"
  (assemble-c2nloader :title "ARUKANOIDO"
                      :path-in "arukanoido/arukanoido.pal.prg"
                      :path-out "arukanoido/arukanoido.pal.tap"
                      :src-prefix "c2nwarp/"))

(with-temporary *path-main* "arukanoido/arukanoido.ntsc.prg"
  (assemble-c2nloader :title "ARUKANOIDO"
                      :path-in "arukanoido/arukanoido.ntsc.prg"
                      :path-out "arukanoido/arukanoido.ntsc.tap"
                      :src-prefix "c2nwarp/"))

(quit)
