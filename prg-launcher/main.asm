main:
    jmp start

prg:
if @*show-cpu?*
    @(fetch-file "obj/arukanoido-cpumon.exo.prg")
end
if @(not *show-cpu?*)
    @(fetch-file "obj/arukanoido-disk.exo.prg")
end
prg_end:
