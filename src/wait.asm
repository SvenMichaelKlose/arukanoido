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
    pha
    txa
    pha
    jsr exm_work
    pla
    tax
    pla
end

    cmp framecounter
    beq -l

    dex
    bne wait
    rts
