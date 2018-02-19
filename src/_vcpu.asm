setzw=1
setsd=2
clrmb=3
clrmw=4
movmw=5
setmb=6
setmw=7
apply=8
syscall_vectors_l: <i_setzw <i_setsd <i_clrmb <i_clrmw <i_movmw <i_setmb <i_setmw <i_apply
syscall_vectors_h: >i_setzw >i_setsd >i_clrmb >i_clrmw >i_movmw >i_setmb >i_setmw >i_apply
syscall_args_l: <args_setzw <args_setsd <args_clrmb <args_clrmw <args_movmw <args_setmb <args_setmw <args_apply
syscall_args_h: >args_setzw >args_setsd >args_clrmb >args_clrmw >args_movmw >args_setmb >args_setmw >args_apply
args_setzw: 3 a0 a1 a2
args_setsd: 4 a0 a1 a2 a3
args_clrmb: 3 dl dh cl
args_clrmw: 4 dl dh cl ch
args_movmw: 6 sl sh dl dh cl ch
args_setmb: 4 dl dh cl a3
args_setmw: 5 dl dh cl ch a4
args_apply: 0
