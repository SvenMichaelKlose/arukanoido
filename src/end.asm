    fill @(- #x10 (mod *pc* #x10))
the_end:
if @*rom?*
    fill @(- #xc000 *pc*)
end
