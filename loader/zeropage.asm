screen      = $1e00
colors      = $9600
buffer_start_hi = $50
buffer_len_hi = $01
decrunch_table = $6000

    org 0

    data

s:  0 0
d:  0 0
c:  0 0

tape_ptr:           0 0
tape_counter:       0 0
tape_callback:      0 0
tape_current_byte:  0
tape_bit_counter:   0
tape_leader_countdown: 0
tape_old_irq:       0 0

debug:              0

exo_s:              0 0
exo_x:              0
exo_y:              0
exo_y2:             0

zp_src_hi:      0                                                                                                                                                                                     
zp_src_lo:      0
zp_src_bi:      0
zp_bitbuf:      0

zp_len_lo:      0 0
zp_bits_lo:     0
zp_bits_hi:     0
zp_dest_hi:     0
zp_dest_lo:     0
zp_dest_bi:     0

mg_s:           0 0
mg_d:           0 0
mg_c:           0 0

tmp:            0 0
tmp2:           0

    end
