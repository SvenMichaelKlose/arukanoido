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

(define-bytecode ldyi sry)
(define-bytecode ldxy srx sry)
(define-bytecode lday sra sry)
(define-bytecode ldsd sl sh dl dh)
(define-bytecode stzb a0 a1)
(define-bytecode stzmb a0 a1 a2)
(define-bytecode stmb a0 a1 a2)
(define-bytecode stmw a0 a1 a2 a3)
(define-bytecode stzw a0 a1 a2)
(define-bytecode inczbi a0)
(define-bytecode addzbi a0 a1)
(define-bytecode mvmzw a0 a1 a2)
(define-bytecode mvmw a0 a1 a2 a3)
(define-bytecode clrmw dl dh cl ch)
(define-bytecode movmw sl sh dl dh cl ch)
(define-bytecode setmw dl dh cl ch a4)
(define-bytecode apply) ; Argument is destination address.
(define-bytecode call a0 a1)

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
