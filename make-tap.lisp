(load "c2nwarp/make.lisp")

(with-temporary *path-main* "arukanoido/arukanoido.prg"
  (assemble-c2nloader :title "ARUKANOIDO"
                      :path-in "arukanoido/arukanoido.prg"
                      :path-out "arukanoido/arukanoido.tap"
                      :src-prefix "c2nwarp/"))

(quit)
