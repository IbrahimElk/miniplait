#lang plait

;; =============================================================================
;; Typed Interpreter: updated-interp.rkt
;; =============================================================================

(require "support.rkt"
         (rename-in (typed-in "err-support.rkt"
                              [raise-type-error : (String -> 'a)]
                              [raise-interp-error : (String -> 'b)])))

(define (eval [str : S-Exp]): Value
  (interp (desugar (parse str))))

;; DO NOT EDIT ABOVE THIS LINE =================================================

;; NOTE: Ibrahim
;; interpret the *syntax* of Typed miniPlait, 
;; but with the same, “untyped” *semantics* of
;; the interpreter.

;; -----------------------------------------------------
;; ERROR SUPPORT FUNCTION
;; -----------------------------------------------------

(value->string : (Value -> String))
(define (value->string v)
  (type-case Value v
    [(v-str a) 
     (string-append "string: \"" (string-append a "\""))]
    [(v-num a)      "number"]
    [(v-bool a) 
     (string-append "boolean: " (if a "true" "false"))]
    [(v-fun p b e) 
     (string-append "function: parameter " (symbol->string p))]
    [(v-list vals)  "list"]))

;; -----------------------------------------------------
;; ENV FUNCTIONS
;; -----------------------------------------------------

(define empty-env (hash empty))

(lookup : (Env Symbol -> Value))
(define (lookup env s)
  (type-case (Optionof Value) (hash-ref env s)
    [(none) (raise-interp-error (string-append (symbol->string s) " is not bound"))]
    [(some value) value]))

(extend : (Env Symbol Value -> Env))
(define (extend old-env new-name value)
  (hash-set old-env new-name value))

;; -----------------------------------------------------
;; MAIN
;; -----------------------------------------------------

(desugar : (Expr+ -> Expr))
(define (desugar expr)
  (type-case Expr+ expr
    [(e-num+    n)        (e-num        n)]
    [(e-str+    s)        (e-str        s)]
    [(e-bool+   b)        (e-bool       b)]
    [(e-empty+  t)        (e-empty      t)]
    [(e-var+    s)        (desugar-var  s)]
    [(e-app+    f a)      (desugar-app  f a)]
    [(sugar-and l r)      (desugar-and  l r)]
    [(sugar-or  l r)      (desugar-or   l r)]
    [(e-un-op+  p e)      (desugar-uop  p e)]
    [(e-op+     p l r)    (desugar-op   p l r)]
    [(e-if+     f a b)    (desugar-if   f a b)]
    [(e-lam+    s a b)    (desugar-lam  s a b)]
    [(sugar-let s v t b)  (desugar-let  s v t b)]
  )
)

(define (interp [expr : Expr]): Value
  (interp-with-env expr empty-env)
)

(interp-with-env : (Expr Env -> Value))
(define (interp-with-env expr env)  
  (type-case Expr expr
    [(e-num n)          (v-num n)]
    [(e-str s)          (v-str s)]
    [(e-bool b)         (v-bool b)]
    [(e-var v)          (interp-with-env-var v env)]
    [(e-op op l r)      (interp-with-env-op  op l r env)]
    [(e-un-op op e)     (interp-with-env-uop op e   env)]
    [(e-if c a b)       (interp-with-env-if  c a b env)]
    [(e-lam p a b)      (interp-with-env-lam p a b env)]
    [(e-app f a)        (interp-with-env-app f a env)]
    [(e-empty t)        (interp-with-env-emp t env)]
  )
)

;; -----------------------------------------------------
;; -----------------------------------------------------
;;  INTERPRETER 
;; -----------------------------------------------------
;; -----------------------------------------------------

;; -----------------------------------------------------
;; INTERP VAR 
;; -----------------------------------------------------

(interp-with-env-var : (Symbol Env -> Value))
(define (interp-with-env-var s env)
  (lookup env s)
)

;; -----------------------------------------------------
;; INTERP EMP operator 
;; -----------------------------------------------------

(interp-with-env-emp : (Type Env -> Value))
(define (interp-with-env-emp t env)
  (v-list empty)
)

;; -----------------------------------------------------
;; INTERP OP OPERATOR
;; -----------------------------------------------------

(interp-with-env-op : (Operator Expr Expr Env -> Value))
(define (interp-with-env-op o l r env)
  (let ([vl (interp-with-env l env)]
        [vr (interp-with-env r env)])
    (type-case Operator o
      [(op-plus)    (madd    vl vr)]
      [(op-append)  (mappend vl vr)] 
      [(op-str-eq)  (mstr-eq vl vr)]
      [(op-num-eq)  (mnum-eq vl vr)]
      [(op-link)    (mlink   vl vr)])
  )
)

(madd : (Value Value -> Value))
(define (madd l r)
  (type-case Value l
    [(v-num l)
      (type-case Value r
        [(v-num r)(v-num (+ l r))]
        [else (raise-interp-error 
          (string-append "In op-plus, "
          (string-append "expected a number for the second argument, "
          (string-append "but received a " (value->string r)))))])]
    [else (raise-interp-error 
      (string-append "In op-plus, "
      (string-append "expected a number for the first argument, "
      (string-append "but received a " (value->string l)))))]
  )
)

(mappend : (Value Value -> Value))
(define (mappend l r)
  (type-case Value l
    [(v-str l)
      (type-case Value r
        [(v-str r)(v-str(string-append l r))]
        [else (raise-interp-error
          (string-append "In op-append, "
          (string-append "expected a string for the second argument, "
          (string-append "but received a " (value->string r)))))])]
    [else (raise-interp-error 
      (string-append "In op-append, " 
      (string-append "expected a string for the first argument, "
      (string-append "but received a " (value->string l)))))]
  )
)

(mstr-eq : (Value Value -> Value))
(define (mstr-eq l r)
  (type-case Value l
    [(v-str l)
      (type-case Value r
        [(v-str r)(v-bool(string=? l r))]
        [else (raise-interp-error 
          (string-append "In op-str-eq, "
          (string-append "expected a string for the second argument, "
          (string-append "but received a " (value->string r)))))])]
    [else (raise-interp-error 
      (string-append "In op-str-eq, "
      (string-append "expected a string for the first argument, "
      (string-append "but received a " (value->string l)))))]

  )
)

(mnum-eq : (Value Value -> Value))
(define (mnum-eq l r)
  (type-case Value l
    [(v-num l)
      (type-case Value r
        [(v-num r)(v-bool (= l r))]
        [else (raise-interp-error 
          (string-append "In op-num-eq, "
          (string-append "expected a number for the second argument, "
          (string-append "but received a " (value->string r)))))])]
    [else (raise-interp-error 
      (string-append "In op-num-eq, "
      (string-append "expected a number for the first argument, "
      (string-append "but received a " (value->string l)))))]

  )
)

(mlink : (Value Value -> Value))
(define (mlink l r)
  (type-case Value r
    [(v-list b) (v-list (cons l b))]
    [else (raise-interp-error 
      (string-append "In op-link, "
      (string-append "expected a list for the second argument, "
      (string-append "but received a " (value->string r)))))]
  )
)

;;-----------------------------------------------------
;; INTERP UOP OPERATOR
;; -----------------------------------------------------

(interp-with-env-uop : (UnaryOperator Expr Env -> Value))
(define (interp-with-env-uop uop e env)
  (let ([ve (interp-with-env e env)])
    (type-case UnaryOperator uop
      [(op-first)     (mfirst    ve)]
      [(op-rest)      (mrest     ve)] 
      [(op-is-empty)  (mis-empty ve)])
  )
)

(mfirst : (Value -> Value))
(define (mfirst e)
  (type-case Value e
    [(v-list l) (check-list-first l)]
    [else (raise-interp-error 
      (string-append "In op-first, "
      (string-append "expected a list as argument, but received a " 
                      (value->string e))))]
  )
)

(check-list-first : ((Listof Value) -> Value))
(define (check-list-first l)
  (if (empty? l)
    (raise-interp-error 
      (string-append "In op-first, "
      (string-append "expected a non empty list as argument, "
                     "but received an empty list")))
    (first l)
  )
)

(mrest : (Value -> Value))
(define (mrest e)
  (type-case Value e
    [(v-list l) (check-list-rest l)]
    [else (raise-interp-error 
      (string-append "In op-rest, "
      (string-append "expected a list as argument, but received a " 
                      (value->string e))))]
  )
)

(check-list-rest : ((Listof Value) -> Value))
(define (check-list-rest l)
  (if (empty? l)
    (raise-interp-error 
      (string-append "In op-rest "
      (string-append "expected a non empty list as argument, "
                     "but received an empty list")))
    (v-list (rest l))
  )
)

(mis-empty : (Value -> Value))
(define (mis-empty e)
  (type-case Value e
    [(v-list l) (v-bool (empty? l))]
    [else (raise-interp-error 
      (string-append "In op-is-empty, "
      (string-append "expected a list as argument, but received a " 
                      (value->string e))))]
  )
)

;;-----------------------------------------------------
;; INTERP IF OPERATOR
;; -----------------------------------------------------

(interp-with-env-if : (Expr Expr Expr Env -> Value))
(define (interp-with-env-if c a b env)
  (let* ([cv  (interp-with-env c env)])
    (type-case Value cv
      [(v-bool cb)(mif cb a b env)]
      [else (raise-interp-error 
        (string-append "In if, "
        (string-append "expected a boolean as condition, "
        (string-append "but received a " (value->string cv)))))]
    )
  )
)

(mif : (Boolean Expr Expr Env -> Value))
(define (mif c a b env)
  (if c 
    (interp-with-env a env)
    (interp-with-env b env))
)

;; -----------------------------------------------------
;; INTERP LAM OPERATOR
;; -----------------------------------------------------

(interp-with-env-lam : (Symbol Type Expr Env -> Value))
(define (interp-with-env-lam p t b env) (v-fun p b env))

;; -----------------------------------------------------
;; INTERP APP OPERATOR
;; -----------------------------------------------------

(interp-with-env-app : (Expr Expr Env -> Value))
(define (interp-with-env-app f arg env)
  (let ([fun-val (interp-with-env f env)])
    (mapp fun-val arg env)))

(mapp : (Value Expr Env -> Value))
(define (mapp fun-val arg env)
  (type-case Value fun-val
    [(v-fun p b fun-env)
        (let* ([arg-val (interp-with-env arg env)]
               [new-env (extend fun-env p arg-val)])
          (begin
            ;; (display (string-append "Applying function with " 
            ;;          (string-append (symbol->string p) "\n")))
            (interp-with-env b new-env)))]
    [else (raise-interp-error 
      (string-append "In app, "
      (string-append "expected a function, but received a " 
                      (value->string fun-val))))]
  )
)

;; -----------------------------------------------------
;; -----------------------------------------------------
;; DESUGARER 
;; -----------------------------------------------------
;; -----------------------------------------------------

;; -----------------------------------------------------
;; DESUGAR VAR OPERATOR 
;; -----------------------------------------------------

(desugar-var : (Symbol -> Expr))
(define (desugar-var s)
  (e-var s)
)

;; -----------------------------------------------------
;; DESUGAR OP OPERATOR 
;; -----------------------------------------------------

(desugar-op : (Operator Expr+ Expr+ -> Expr))
(define (desugar-op o l r)
  (let* ([new-l (desugar l)]
         [new-r (desugar r)])
  (e-op o new-l new-r))
)

;; -----------------------------------------------------
;; DESUGAR UOP OPERATOR 
;; -----------------------------------------------------

(desugar-uop : (UnaryOperator Expr+ -> Expr))
(define (desugar-uop o e)
  (let* ([new-e (desugar e)])
  (e-un-op o new-e))
)

;; -----------------------------------------------------
;; DESUGAR IF OPERATOR 
;; -----------------------------------------------------

(desugar-if : (Expr+ Expr+ Expr+ -> Expr))
(define (desugar-if c a b)
  (let* ([new-c (desugar c)]
         [new-a (desugar a)]
         [new-b (desugar b)])
  (e-if new-c new-a new-b))
)

;; -----------------------------------------------------
;; DESUGAR AND OPERATOR 
;; -----------------------------------------------------

(desugar-and : (Expr+ Expr+ -> Expr))
(define (desugar-and l r)
  (let* ([new-l (desugar l)]
         [new-r (desugar r)])
  (e-if new-l 
    (e-if new-r (e-bool #t) (e-bool #f)) 
    (e-bool #f)
  ))
)

;; -----------------------------------------------------
;; DESUGAR OR OPERATOR 
;; -----------------------------------------------------

(desugar-or : (Expr+ Expr+ -> Expr))
(define (desugar-or l r)
  (let* ([new-l (desugar l)]
         [new-r (desugar r)])
  (e-if new-l 
    (e-bool #t)
    (e-if new-r (e-bool #t) (e-bool #f))
  ))
)

;; -----------------------------------------------------
;; DESUGAR LAM OPERATOR 
;; -----------------------------------------------------

(desugar-lam : (Symbol Type Expr+ -> Expr))
(define (desugar-lam s t b)
  (let* ([new-b (desugar b)])
  (e-lam s t new-b))
)

;; -----------------------------------------------------
;; DESUGAR APP OPERATOR 
;; -----------------------------------------------------

(desugar-app : (Expr+ Expr+ -> Expr))
(define (desugar-app f a)
  (let* ([new-f (desugar f)]
         [new-a (desugar a)])
  (e-app new-f new-a))
)

;; -----------------------------------------------------
;; DESUGAR LET OPERATOR 
;; -----------------------------------------------------

(desugar-let : (Symbol Expr+ Type Expr+ -> Expr))
(define (desugar-let s v t b)
  (let* ([new-v (desugar v)]
         [new-b (desugar b)])
  (e-app (e-lam s t new-b) new-v)
  )
)
