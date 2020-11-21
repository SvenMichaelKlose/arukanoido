(fn make-prg-launcher ()
  (make (? *show-cpu?*
           "arukanoido-cpumon.prg"
           "arukanoido2.prg")
        (@ [+ "prg-launcher/" _] `("../bender/vic-20/vic.asm"
                                   "zeropage.asm"
                                   "../bender/vic-20/basic-loader.asm"
                                   "main.asm"
                                   "start.asm"
                                   "blk5.asm"
                                   ,@(when *has-digis?*
                                       '("../src/music-arcade-blk5.asm"))
                                   "blk5-end.asm"))
        "obj/prg-launcher.vice.txt"))
