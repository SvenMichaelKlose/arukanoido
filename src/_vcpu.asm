stmb=1
stmw=2
stzb=3
stzmb=4
stzw=5
mvmw=6
lday=7
ldsd=8
clrmb=9
clrmw=10
movmw=11
setmb=12
setmw=13
apply=14
call=15
syscall_vectors_l: <i_stmb <i_stmw <i_stzb <i_stzmb <i_stzw <i_mvmw <i_lday <i_ldsd <i_clrmb <i_clrmw <i_movmw <i_setmb <i_setmw <i_apply <i_call
syscall_vectors_h: >i_stmb >i_stmw >i_stzb >i_stzmb >i_stzw >i_mvmw >i_lday >i_ldsd >i_clrmb >i_clrmw >i_movmw >i_setmb >i_setmw >i_apply >i_call
syscall_args_l: <args_stmb <args_stmw <args_stzb <args_stzmb <args_stzw <args_mvmw <args_lday <args_ldsd <args_clrmb <args_clrmw <args_movmw <args_setmb <args_setmw <args_apply <args_call
syscall_args_h: >args_stmb >args_stmw >args_stzb >args_stzmb >args_stzw >args_mvmw >args_lday >args_ldsd >args_clrmb >args_clrmw >args_movmw >args_setmb >args_setmw >args_apply >args_call
args_stmb: 3 a0 a1 a2
args_stmw: 4 a0 a1 a2 a3
args_stzb: 2 a0 a1
args_stzmb: 3 a0 a1 a2
args_stzw: 3 a0 a1 a2
args_mvmw: 4 a0 a1 a2 a3
args_lday: 2 sra sry
args_ldsd: 4 sl sh dl dh
args_clrmb: 3 dl dh cl
args_clrmw: 4 dl dh cl ch
args_movmw: 6 sl sh dl dh cl ch
args_setmb: 4 dl dh cl a3
args_setmw: 5 dl dh cl ch a4
args_apply: 0
args_call: 2 a0 a1
