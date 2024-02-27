wait:
if @*shadowvic?*
    $22 $02
    dex
    bne wait
    rts
end

    lda framecounter
l:
if @*has-digis?*
    jsr exm_work
end

    cmp framecounter
    beq -l

    dex
    bne wait
    rts
