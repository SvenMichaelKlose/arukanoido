(var *bytecodes* nil)

(fn syscallbyindex (x)
  (elt *bytecodes* x))

(fn syscall-name (x)
  (downcase (symbol-name x.)))

(fn syscall-bytecodes-source ()
  (apply #'+ (maptimes [format nil "~A=~A~%" (syscall-name (syscallbyindex _))
                                               (++ _)]
                       (length *bytecodes*))))

(fn syscall-vectors (label prefix)
  (+ label ": "
     (apply #'+ (pad (mapcar [format nil "~A~A" prefix (syscall-name _)]
                             *bytecodes*)
                     " "))
     (format nil "~%")))

(fn syscall-vectors-l () (syscall-vectors "syscall_vectors_l" "<i_"))
(fn syscall-vectors-h () (syscall-vectors "syscall_vectors_h" ">i_"))
(fn syscall-args-l () (syscall-vectors "syscall_args_l" "<args_"))
(fn syscall-args-h () (syscall-vectors "syscall_args_h" ">args_"))

(fn syscall-args ()
  (apply #'+ (mapcar [+ (format nil "args_~A: " (syscall-name _))
                        (apply #'+ (pad (+ (list (princ (length ._) nil))
									       (mapcar [downcase (symbol-name _)] ._))
										" "))
						(format nil "~%")]
                     *bytecodes*)))

(defmacro define-bytecode (name &rest args)
  (| (assoc name *bytecodes*)
     (acons! name args *bytecodes*))
  nil)

(define-bytecode setzw a0 a1 a2)        ; zp, word
(define-bytecode setsd a0 a1 a2 a3)     ; <s, >s, <d, >d
(define-bytecode clrmb a0 a1 a2)        ; <d, >d, l
(define-bytecode clrmw a0 a1 a2 a3)     ; <d, >d, <l, >l
(define-bytecode movmw a0 a1 a2 a3 a4 a5) ; <s, >s, <d, >d, <l, >l
(define-bytecode setmb a0 a1 a2 a3)     ; <d, >d, <l, value
(define-bytecode setmw a0 a1 a2 a3 a4)  ; <d, >d, <l, >l, value
(define-bytecode apply) ; Argument is destination address.

(= *bytecodes* (reverse *bytecodes*))

(fn gen-vcpu-tables (path)
  (with-output-file o path
    (princ (+ (syscall-bytecodes-source)
              (syscall-vectors-l)
              (syscall-vectors-h)
              (syscall-args-l)
              (syscall-args-h)
              (syscall-args))
           o)))
