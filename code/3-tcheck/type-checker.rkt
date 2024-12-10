#lang plait

;; =============================================================================
;; Type Checker: type-checker.rkt
;; =============================================================================

(require "support.rkt")

(define (type-check [str : S-Exp]): Type
  (type-of (parse str)))

;; DO NOT EDIT ABOVE THIS LINE =================================================


;; -----------------------------------------------------
;; ERROR SUPPORT FUNCTION
;; -----------------------------------------------------

(type->string : (Type -> String))
(define (type->string t)
  (type-case Type t
    [(t-str)      "string"]
    [(t-num)      "number"]
    [(t-bool)     "boolean"]
    [(t-fun a r)  (string-append "function: " 
                  (string-append (type->string a) 
                  (string-append " -> " (type->string r))))]
    [(t-list l)   (string-append "list of " (type->string l))]))

;; -----------------------------------------------------
;; ENV FUNCTIONS
;; -----------------------------------------------------

(define empty-env (hash empty))

(lookup : (TEnv Symbol -> Type))
(define (lookup env s)
  (type-case (Optionof Type) (hash-ref env s)
    [(none) (error 'TypeError (string-append (symbol->string s)
                                             " identifier not bound"))]
    [(some type) type]))

(extend : (TEnv Symbol Type -> TEnv))
(define (extend old-env new-name type)
  (hash-set old-env new-name type))

;; (define empty-env (make-hash empty))
;;
;; (lookup : (TEnv Symbol -> Type))
;; (define (lookup env s)
;;   (type-case (Optionof Type) (hash-ref env s)
;;     [(none) (error s " not bound")]
;;     [(some type) type]))
;;
;; (extend : (TEnv Symbol Type -> TEnv))
;; (define (extend old-env new-name type)
;;   (let ([_ (hash-set! old-env new-name type)])
;;     old-env)
;; )

;; -----------------------------------------------------
;; MAIN FUNCTIONS
;; -----------------------------------------------------

(define (type-of [expr : Expr]): Type
  (type-of-with-env expr empty-env)   
)

(type-of-with-env : (Expr TEnv -> Type))
(define (type-of-with-env expr env)
  (type-case Expr expr
    [(e-num n)      (t-num)]
    [(e-bool b)     (t-bool)]
    [(e-str s)      (t-str)]
    [(e-op op l r)  (type-of-with-env-op   op l r env)]
    [(e-un-op op e) (type-of-with-env-uop  op e env)]
    [(e-if c a b)   (type-of-with-env-if   c a b env)]
    [(e-lam p t b)  (type-of-with-env-lam  p t b env)]
    [(e-app f a)    (type-of-with-env-app  f a env)]
    [(e-id n)       (type-of-with-env-id   n env)]
    [(e-let i v b)  (type-of-with-env-let  i v b env)]
    [(e-empty t)    (type-of-with-env-emp  t env)]
  )
)

;; -----------------------------------------------------
;; VAR OPERATOR
;; -----------------------------------------------------

(type-of-with-env-id : (Symbol TEnv -> Type))
(define (type-of-with-env-id s env)
  (lookup env s)
)

;; -----------------------------------------------------
;; EMPTY OPERATOR
;; -----------------------------------------------------

(type-of-with-env-emp : (Type TEnv -> Type))
(define (type-of-with-env-emp t env)
  (t-list t)
)

;; -----------------------------------------------------
;; OP OPERATOR
;; -----------------------------------------------------

(type-of-with-env-op : (Operator Expr Expr TEnv -> Type))
(define (type-of-with-env-op op l r env)
  (let ([tl (type-of-with-env l env)]
        [tr (type-of-with-env r env)])
    (type-case Operator op
      [(op-plus)    (maddt    tl tr)]
      [(op-append)  (mappendt tl tr)] 
      [(op-str-eq)  (mstr-eqt tl tr)]
      [(op-num-eq)  (mnum-eqt tl tr)]
      [(op-link)    (mlinkt   tl tr)])
  )
)

(maddt : (Type Type -> Type))
(define (maddt l r)
  (type-case Type l
    [(t-num)
      (type-case Type r
        [(t-num)(t-num)]
        [else (error 'TypeError 
                (string-append "incorrect type of second argument to add, " 
                (string-append "should be number but you have given " 
                               (type->string r)))
                )])]
    [else (error 'TypeError 
                 (string-append "incorrect type of first argument to add, "
                 (string-append "should be number but you have given "
                                (type->string l))))]
  )
)

(mappendt : (Type Type -> Type))
(define (mappendt l r)
  (type-case Type l
    [(t-str)
      (type-case Type r
        [(t-str)(t-str)]
        [else (error 'TypeError 
                (string-append "incorrect type of second argument to append, " 
                (string-append "should be string but you have given " 
                               (type->string r)))
                )])]
    [else (error 'TypeError 
                 (string-append "incorrect type of first argument to append, "
                 (string-append "should be string but you have given "
                                (type->string l))))]
  )
)

(mstr-eqt : (Type Type -> Type))
(define (mstr-eqt l r)
  (type-case Type l
    [(t-str)
      (type-case Type r
        [(t-str)(t-bool)]
        [else (error 'TypeError
                (string-append "incorrect type of second argument to str= , " 
                (string-append "should be string but you have given " 
                               (type->string r)))
                )])]
    [else (error 'TypeError 
                 (string-append "incorrect type of first argument to str= , "
                 (string-append "should be string but you have given "
                                (type->string l))))]
  )
)

(mnum-eqt : (Type Type -> Type))
(define (mnum-eqt l r)
  (type-case Type l
    [(t-num)
      (type-case Type r
        [(t-num)(t-bool)]
        [else (error 'TypeError 
                (string-append "incorrect type of second argument to num= , " 
                (string-append "should be number but you have given " 
                               (type->string r)))
                )])]
    [else (error 'TypeError 
                 (string-append "incorrect type of first argument to num= , "
                 (string-append "should be number but you have given "
                                (type->string l))))]
  )
)

;; NOTE Ibrahim
;; list are homogeneous
(mlinkt : (Type Type -> Type))
(define (mlinkt l r)
  (type-case Type r
    [(t-list a) (check-and-type l a)]
    [else (error 'TypeError 
            (string-append "incorrect type of second argument to link , "
            (string-append "should be a list but you have given "
                           (type->string r))))]
  )
)

(check-and-type : (Type Type -> Type))
(define (check-and-type l a)
  (if (equal? l a)
    (t-list l)
    (error 'TypeError 
            (string-append "incorrect type of first argument to link , "
            (string-append "should be the same type as the type of list "
            (string-append "in the second argument of link, but you have given "
                           (type->string l)))))
  )
)

;;-----------------------------------------------------
;; UOP OPERATOR
;; -----------------------------------------------------

(type-of-with-env-uop : (UnaryOperator Expr TEnv -> Type))
(define (type-of-with-env-uop uop e env)
  (let ([te (type-of-with-env e env)])
    (type-case UnaryOperator uop
      [(op-first)     (mfirstt    te)]
      [(op-rest)      (mrestt     te)] 
      [(op-is-empty)  (mis-emptyt te)])
  )
)

;; NOTE Ibrahim
;; if List is of type List T 
;; then first is of type T
(mfirstt : (Type -> Type))
(define (mfirstt t)
  (type-case Type t
    [(t-list T) T]
    [else (error 'TypeError 
            (string-append "incorrect type of argument to first , "
            (string-append "should be a list but you have given "
                           (type->string t))))]
  )
)

;; NOTE Ibrahim
;; if List is of type List T 
;; then rest is of type List T
(mrestt : (Type -> Type))
(define (mrestt t)
  (type-case Type t
    [(t-list T) t]
    [else (error 'TypeError 
            (string-append "incorrect type of argument to rest , "
            (string-append "should be a list but you have given "
                           (type->string t))))]
  )
)

(mis-emptyt : (Type -> Type))
(define (mis-emptyt t)
  (type-case Type t
    [(t-list T) (t-bool)]
    [else (error 'TypeError 
            (string-append "incorrect type of argument to is-empty , "
            (string-append "should be a list but you have given "
                           (type->string t))))]
  )
)

;;-----------------------------------------------------
;; IF OPERATOR
;; -----------------------------------------------------

(type-of-with-env-if : (Expr Expr Expr TEnv -> Type))
(define (type-of-with-env-if c a b env)
  (let ([ct (type-of-with-env c env)])
    (type-case Type ct
      [(t-bool)(mift ct a b env)]
      [else (error 'TypeError
            (string-append "incorrect type of condition to if , "
            (string-append "should be a boolean but you have given "
                           (type->string ct))))])
  )
)

;; NOTE Ibrahim
;; branches of if expression should be of 
;; the same type.
(mift : (Boolean Expr Expr TEnv -> Type))
(define (mift c a b env)
  (let ([at (type-of-with-env a env)]
        [bt (type-of-with-env b env)])
    (if (equal? at bt)
        at
        (error 'TypeError
          (string-append "In if, "
          (string-append "expected the two branches to return the same type, " 
          (string-append "but received " 
          (string-append (type->string at) 
          (string-append " and "
                         (type->string bt))))))))
  )
)

;; -----------------------------------------------------
;; LAM OPERATOR
;; -----------------------------------------------------

(type-of-with-env-lam : (Symbol Type Expr TEnv -> Type))
(define (type-of-with-env-lam p t b env)
  (let* ([new-env (extend env p t)]
         [bt      (type-of-with-env b new-env)])
  (t-fun t bt))
)

;; -----------------------------------------------------
;; APP OPERATOR
;; -----------------------------------------------------

(type-of-with-env-app : (Expr Expr TEnv -> Type))
(define (type-of-with-env-app f arg env)
  (let ([fun-type (type-of-with-env f env)])
    (mappt fun-type arg env)))

(mappt : (Type Expr TEnv -> Type))
(define (mappt fun-type arg env)
  (type-case Type fun-type
    [(t-fun formal-argt returnt)
      (let  ([actual-argt (type-of-with-env arg env)])
        (if (equal? actual-argt formal-argt)
          returnt
          (error 'TypeError
            (string-append "In app, "
            (string-append "expected actual argument type "
            (string-append "to be equal to the formal "
            (string-append "argument type, but received "
            (string-append (type->string actual-argt)
            (string-append " and "
                           (type->string formal-argt))))))))))]

    [else (error 'TypeError 
            (string-append "In app, expected a function, but received a " 
                           (type->string fun-type)))]
  )
)



;; -----------------------------------------------------
;; LET OPERATOR
;; -----------------------------------------------------

(type-of-with-env-let : (Symbol Expr Expr TEnv -> Type))
(define (type-of-with-env-let i v b env)
  (let* ([id-type (type-of-with-env v env)]
         [new-env (extend env i id-type)])
  (type-of-with-env b new-env))
)

