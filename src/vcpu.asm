inc_bcp:
    inc bcp
    bne +n
    inc @(++ bcp)
n:  rts

inc_bca:
    inc bca
    bne +n
    inc @(++ bca)
n:  rts

exec_script:
    pla ; Y
    pla ; X
    sta srx
    pla ; A
    plp ; flags
    pla
    sta bcp
    pla
    sta @(++ bcp)
    lda bcp
    sec
    sbc #1
    sta bcp
    bcs +n
    dec @(++ bcp)
n:

next_bytecode:
    ; Get opcode.
    ldy #0
    lda (bcp),y
    beq +done       ; Return to native code…

    ; Get pointer to argument info.
    tax
    dex
    lda syscall_vectors_l,x
    sta vcpu_tmp
    lda syscall_vectors_h,x
    sta @(++ vcpu_tmp)
    lda syscall_args_l,x
    sta bca
    lda syscall_args_h,x
    sta @(++ bca)

    ; Get number of arguments.
    lda (bca),y
    sta num_args

    ; Copy arguments to zero page.
next_arg:
    jsr inc_bcp
    dec num_args
    bmi script_call

    jsr inc_bca
    lda (bca),y     ; Get zero page address from argument info.
    tax
    lda (bcp),y     ; Copy in argument value.
    sta 0,x

    jmp next_arg

script_call:
    jsr +j
    jmp next_bytecode
j:  jmp (vcpu_tmp)

    ; Return to native code.
done:
    lda @(++ bcp)
    pha
    lda bcp
    pha
    ldx srx
    rts
