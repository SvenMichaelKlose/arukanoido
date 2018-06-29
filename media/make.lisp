(fn make-media ()
  (put-file "obj/title.bin" (minigrafik-without-code "media/ark-title.prg"))
  (exomize-stream "obj/title.bin" "obj/title.bin.exo")
  (apply #'assemble-files "obj/gfx-ship.bin" '("media/gfx-ship.asm"))
  (exomize-stream "obj/gfx-ship.bin" "obj/gfx-ship.bin.exo")
  (apply #'assemble-files "obj/gfx-taito.bin" '("media/gfx-taito.asm"))
  (exomize-stream "obj/gfx-taito.bin" "obj/gfx-taito.bin.exo")
  (apply #'assemble-files "obj/gfx-background.bin" '("media/gfx-background.asm"))
  (exomize-stream "obj/gfx-background.bin" "obj/gfx-background.bin.exo"))