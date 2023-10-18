(= *model* :vic-20+xk)

(var *pulse-short*      #x20)
(var *pulse-medium*     (* 2 *pulse-short*))
(var *pulse-long*       (* 3 *pulse-short*))

(var *tape-leader-length*   64)
(var *trailer-length*       32)

(fn c2n-leader (o)
  (adotimes ((* 8 *tape-leader-length*) nil)
    (write-byte *pulse-medium* o))
  (write-byte *pulse-short* o)) ; Signalling end of leader.

(fn c2nbit (o x)
  (write-byte (? (== 0 x) *pulse-short* *pulse-medium*) o))

(fn c2nbyte (o x)
  (dotimes (bits 8)
    (c2nbit o (bit-and (>> x bits) 1))))

(fn c2n-trailer (o)
  (adotimes *trailer-length*
    (write-byte *pulse-medium* o)))

(fn c2ntap (o i &key (gap #x8000000))
  (awhen gap
    (write-dword ! o))
  (c2n-leader o)
  (awhile (read-byte i) nil
    (c2nbyte o !))
  (c2n-trailer o))
