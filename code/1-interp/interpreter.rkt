#lang plait

;; =============================================================================
;; Interpreter: interpreter.rkt
;; =============================================================================

(require "support.rkt")

(define (eval [str : S-Exp]): Value
  (interp (parse str)))

;; DO NOT EDIT ABOVE THIS LINE =================================================

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
  )
)

;; -----------------------------------------------------
;; ENV FUNCTIONS
;; -----------------------------------------------------

(define empty-env (hash empty))

(lookup : (Env Symbol -> Value))
(define (lookup env s)
  (type-case (Optionof Value) (hash-ref env s)
    [(none) (error 'interp-error 
                   (string-append (symbol->string s) " is not bound"))]
    [(some value) value]))

(extend : (Env Symbol Value -> Env))
(define (extend old-env new-name value)
  (hash-set old-env new-name value))

;; -----------------------------------------------------
;; MAIN
;; -----------------------------------------------------

(define (interp [expr : Expr]): Value
  (interp-with-env expr empty-env)
)


(interp-with-env : (Expr Env -> Value))
(define (interp-with-env expr env)  
  (type-case Expr expr
    [(e-num n)      (v-num n)]
    [(e-str s)      (v-str s)]
    [(e-bool b)     (v-bool b)]
    [(e-var v)      (interp-with-env-var v env)]
    [(e-op op l r)  (interp-with-env-op op l r env)]
    [(e-if c a b)   (interp-with-env-if c a b env)]
    [(e-lam p b)    (interp-with-env-lam p b env)]
    [(e-app f a)    (interp-with-env-app f a env)]
  )
)

;; -----------------------------------------------------
;; VAR OPERATOR
;; -----------------------------------------------------

(interp-with-env-var : (Symbol Env -> Value))
(define (interp-with-env-var s env)
  (begin
     ;; (display (string-append "looking up " 
     ;;          (string-append (symbol->string s) "\n")))
     (lookup env s)
    )
)

;; -----------------------------------------------------
;; OP OPERATOR
;; -----------------------------------------------------

(interp-with-env-op : (Operator Expr Expr Env -> Value))
(define (interp-with-env-op o l r env)
  (let ([vl (interp-with-env l env)]
        [vr (interp-with-env r env)])
    (type-case Operator o
      [(op-plus)    (madd    vl vr)]
      [(op-append)  (mappend vl vr)] 
      [(op-str-eq)  (mstr-eq vl vr)]
      [(op-num-eq)  (mnum-eq vl vr)])
  )
)

(madd : (Value Value -> Value))
(define (madd l r)
  (type-case Value l
    [(v-num l)
      (type-case Value r
        [(v-num r)(v-num (+ l r))]
        [else (error 'interp-error
                (string-append "incorrect type of second argument to add, " 
                (string-append "should be number but you have given " 
                               (value->string r)))
                )])]
    [else (error 'interp-error
                 (string-append "incorrect type of first argument to add, "
                 (string-append "should be number but you have given "
                                (value->string l))))]
  )
)

(mappend : (Value Value -> Value))
(define (mappend l r)
  (type-case Value l
    [(v-str l)
      (type-case Value r
        [(v-str r)(v-str(string-append l r))]
        [else (error 'interp-error
                (string-append "incorrect type of second argument to ++ , " 
                (string-append "should be string but you have given " 
                               (value->string r)))
                )])]
    [else (error 'interp-error
                 (string-append "incorrect type of first argument to ++ , "
                 (string-append "should be string but you have given "
                                (value->string l))))]
  )
)

(mstr-eq : (Value Value -> Value))
(define (mstr-eq l r)
  (type-case Value l
    [(v-str l)
      (type-case Value r
        [(v-str r)(v-bool(string=? l r))]
        [else (error 'interp-error
                (string-append "incorrect type of second argument to str= , " 
                (string-append "should be string but you have given " 
                               (value->string r)))
                )])]
    [else (error 'interp-error
                 (string-append "incorrect type of first argument to str= , "
                 (string-append "should be string but you have given "
                                (value->string l))))]
  )
)

(mnum-eq : (Value Value -> Value))
(define (mnum-eq l r)
  (type-case Value l
    [(v-num l)
      (type-case Value r
        [(v-num r)(v-bool (= l r))]
        [else (error 'interp-error
                (string-append "incorrect type of second argument to num= , " 
                (string-append "should be number but you have given " 
                               (value->string r)))
                )])]
    [else (error 'interp-error
                 (string-append "incorrect type of first argument to num= , "
                 (string-append "should be number but you have given "
                                (value->string l))))]
  )
)

;;-----------------------------------------------------
;; IF OPERATOR
;; -----------------------------------------------------

(interp-with-env-if : (Expr Expr Expr Env -> Value))
(define (interp-with-env-if c a b env)
  (let ([cv (interp-with-env c env)])
    (type-case Value cv
      [(v-bool cb)(mif cb a b env)]
      [else (error 'interp-error
                 (string-append "incorrect type of condition argument to if , "
                 (string-append "should be boolean but you have given "
                                (value->string cv))))]
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
;; LAM OPERATOR
;; -----------------------------------------------------

(interp-with-env-lam : (Symbol Expr Env -> Value))
(define (interp-with-env-lam p b env) (v-fun p b env))

;; -----------------------------------------------------
;; APP OPERATOR
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
    [else (error 'interp-error 
                 "Function application error: Expected a function value")]
  )
)


