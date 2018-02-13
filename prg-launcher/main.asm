main:
    jmp start

prg:
    @(fetch-file (+ "obj/" *prg-path* ".exo.prg"))
prg_end:
