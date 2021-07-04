;Control codes
;-------------

silencecode = 127
setvolcode = 126	;volume
volfadecode = 125	;delay for decrease in frames
gotocode = 124		;absolute address
stopcode = 123      ; stop playing
chaincode = 122      ; chain
nullcode = 121      ; do nothing top registers
returncode = 120    ; return to caller
firstcode = 119		;first code

;Macros
;------
.macro c0
    .byte 128
  .endmacro
.macro cSh0
    .byte 134
  .endmacro
.macro d0
    .byte 141
  .endmacro
.macro dSh0
    .byte 147
  .endmacro
.macro e0
    .byte 153
  .endmacro
.macro f0
    .byte 159
  .endmacro
.macro fSh0
    .byte 164
  .endmacro
.macro g0
    .byte 170
  .endmacro
.macro gSh0
    .byte 174
  .endmacro
.macro a0
    .byte 179
  .endmacro
.macro aSh0
    .byte 183
  .endmacro

.macro b0
    .byte 187
  .endmacro
.macro h0
    .byte 187
  .endmacro

 .macro c1
    .byte 191
  .endmacro
.macro cSh1
    .byte 195
  .endmacro
.macro d1
    .byte 198
  .endmacro
.macro dSh1
    .byte 201
  .endmacro
.macro e1
    .byte 204
  .endmacro
.macro f1
    .byte 207
  .endmacro
.macro fSh1
    .byte 210
  .endmacro
.macro g1
    .byte 213
  .endmacro
.macro gSh1
    .byte 215
  .endmacro
.macro a1
    .byte 217
  .endmacro
.macro aSh1
    .byte 219
  .endmacro

.macro h1
    .byte 221
  .endmacro

.macro b1
    .byte 221
.endmacro


  
.macro c2
    .byte 223
  .endmacro
.macro cSh2
    .byte 225
  .endmacro
.macro d2
    .byte 227
  .endmacro
.macro dSh2
    .byte 228
  .endmacro
.macro e2
    .byte 230
  .endmacro
.macro f2
    .byte 231
  .endmacro
.macro fSh2
    .byte 232
  .endmacro
.macro g2
    .byte 234
  .endmacro
.macro gSh2
    .byte 235
  .endmacro
.macro a2
    .byte 236
  .endmacro
.macro aSh2
    .byte 237
  .endmacro

  .macro h2
    .byte 238	
  .endmacro
.macro b2
    .byte 238
  .endmacro

  
.macro c3
    .byte 239
  .endmacro
.macro cSh3
    .byte 240
  .endmacro

;Silence
.macro s
  .byte silencecode
.endmacro

.macro return
  .byte returncode
.endmacro


;Duration
.macro dur d
   .if d >= 121
      .error "Invalid duration",d,", orig", firstcode
   .endif
  .byte d
.endmacro

; null (no op but use up delay)...
.macro null 
  .byte nullcode
.endmacro



;Goto
.macro go address
  .byte gotocode
  .byte (address-chanstart)
  .if address-chanstart > 255
    .error "too long track at", address
  .endif
.endmacro

;delay in frames between each decrement of volume
;Volume fade amt
.macro volfade  amt
  .byte volfadecode,amt
.endmacro

;Set volume (effective from next frame)
.macro volset vol ;volume
  .byte setvolcode,vol
.endmacro

;Set volume (effective from next frame)
.macro chain song 
  .byte chaincode,song
.endmacro


;Silence
.macro stop
  .byte stopcode
.endmacro
