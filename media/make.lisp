(fn make-media ()
  (put-file "obj/title.bin" (minigrafik-without-code "media/ark-title.prg"))
  (exomize-stream "obj/title.bin" "obj/title.bin.exo")
  (apply #'assemble-files "obj/gfx-ship.bin" '("media/gfx-ship.asm"))
  (exomize-stream "obj/gfx-ship.bin" "obj/gfx-ship.bin.exo")
  (apply #'assemble-files "obj/gfx-arukanoido.bin" '("media/gfx-arukanoido.asm"))
  (exomize-stream "obj/gfx-arukanoido.bin" "obj/gfx-arukanoido.bin.exo")
  (apply #'assemble-files "obj/gfx-taito.bin" '("media/gfx-taito.asm"))
  (exomize-stream "obj/gfx-taito.bin" "obj/gfx-taito.bin.exo")
  (apply #'assemble-files "obj/gfx-background.bin" '("media/gfx-background.asm"))
  (exomize-stream "obj/gfx-background.bin" "obj/gfx-background.bin.exo")
  (apply #'assemble-files "obj/round-intro-text.bin" '("media/round-intro-text.asm"))
  (exomize-stream "obj/round-intro-text.bin" "obj/round-intro-text.bin.exo")
  (apply #'assemble-files "obj/gfx-doh.bin" '("src/gfx-doh.asm"))
  (exomize-stream "obj/gfx-doh.bin" "obj/gfx-doh.bin.exo"))
