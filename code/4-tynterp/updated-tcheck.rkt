#lang plait

;; =============================================================================
;; Typed Interpreter: tynterp.rkt
;; =============================================================================

(require "support.rkt"
         (rename-in (typed-in "err-support.rkt"
                              [raise-type-error : (String -> 'a)]
                              [raise-interp-error : (String -> 'b)])))

(define (type-check [str : S-Exp]): Type
  (type-of (desugar (parse str))))

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

(define empty-envt (hash empty))

(lookupt : (TEnv Symbol -> Type))
(define (lookupt env s)
  (type-case (Optionof Type) (hash-ref env s)
    [(none) (raise-type-error
              (string-append (symbol->string s) " not bound"))]
    [(some type) type]))

(extendt : (TEnv Symbol Type -> TEnv))
(define (extendt old-env new-name type)
  (hash-set old-env new-name type))

;; -----------------------------------------------------
;; MAIN
;; -----------------------------------------------------

(define (type-of [expr : Expr]): Type
  (type-of-with-env expr empty-envt)   
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
    [(e-var n)      (type-of-with-env-var  n env)]
    [(e-empty t)    (type-of-with-env-emp  t env)]
  )
)

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

;; -----------------------------------------------------
;; -----------------------------------------------------
;;  TYPE CHECKER 
;; -----------------------------------------------------
;; -----------------------------------------------------

;; -----------------------------------------------------
;; TYPE VAR OPERATOR
;; -----------------------------------------------------

(type-of-with-env-var : (Symbol TEnv -> Type))
(define (type-of-with-env-var s env)
  (lookupt env s)
)

;; -----------------------------------------------------
;; TYPE EMPTY OPERATOR
;; -----------------------------------------------------

(type-of-with-env-emp : (Type TEnv -> Type))
(define (type-of-with-env-emp t env)
  (t-list t)
)

;; -----------------------------------------------------
;; TYPE OP OPERATOR
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
        [else (raise-type-error
          (string-append "In op-plus, "
          (string-append "expected a number for the second argument, "
          (string-append "but received a " (type->string r)))))])]
    [else (raise-type-error
      (string-append "In op-plus, "
      (string-append "expected a number for the first argument, "
      (string-append "but received a " (type->string r)))))]
  )
)

(mappendt : (Type Type -> Type))
(define (mappendt l r)
  (type-case Type l
    [(t-str)
      (type-case Type r
        [(t-str)(t-str)]
        [else (raise-type-error 
          (string-append "In op-append, " 
          (string-append "expected a string for the second argument, "
          (string-append "but received a " (type->string r)))))])]
    [else (raise-type-error
      (string-append "In op-append, "
      (string-append "expected a string for the first argument, "
      (string-append "but received a " (type->string r)))))]
  )
)

(mstr-eqt : (Type Type -> Type))
(define (mstr-eqt l r)
  (type-case Type l
    [(t-str)
      (type-case Type r
        [(t-str)(t-bool)]
        [else (raise-type-error 
          (string-append "In op-str-eq, "
          (string-append "expected a string for the second argument, "
          (string-append "but received a " (type->string r)))))])]
    [else (raise-type-error
      (string-append "In op-str-eq, "
      (string-append "expected a string for the first argument, "
      (string-append "but received a " (type->string r)))))]
  )
)

(mnum-eqt : (Type Type -> Type))
(define (mnum-eqt l r)
  (type-case Type l
    [(t-num)
      (type-case Type r
        [(t-num)(t-bool)]
        [else (raise-type-error 
          (string-append "In op-num-eq, "
          (string-append "expected a number for the second argument, "
          (string-append "but received a " (type->string r)))))])]
    [else (raise-type-error 
      (string-append "In op-num-eq, "
      (string-append "expected a number for the second argument, "
      (string-append "but received a " (type->string r)))))]
  )
)

(mlinkt : (Type Type -> Type))
(define (mlinkt l r)
  (type-case Type r
    [(t-list a) (check-and-type a l)]
    [else (raise-type-error 
      (string-append "In op-link, "
      (string-append "expected a list for the second argument, "
      (string-append "but received a " (type->string r)))))]
  )
)

(define (check-and-type a l) 
  (if (equal? a l)
    (t-list a)
    (raise-type-error
      (string-append "In op-link," 
      (string-append "expected an element of type "
      (string-append (type->string a)
      (string-append "but received an element of type " 
                     (type->string l))))))
    ) 
)

;;-----------------------------------------------------
;; TYPE UOP OPERATOR
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

(mfirstt : (Type -> Type))
(define (mfirstt t)
  (type-case Type t
    [(t-list T) T]
    [else (raise-type-error 
      (string-append "In op-first, "
      (string-append "expected a list as argument, but received a " 
                      (type->string t))))]
  )
)

(mrestt : (Type -> Type))
(define (mrestt t)
  (type-case Type t
    [(t-list T) t]
    [else (raise-type-error 
      (string-append "In op-rest, "
      (string-append "expected a list as argument, but received a " 
                      (type->string t))))]
  )
)

(mis-emptyt : (Type -> Type))
(define (mis-emptyt t)
  (type-case Type t
    [(t-list T) (t-bool)]
    [else (raise-type-error 
      (string-append "In op-is-empty, "
      (string-append "expected a list as argument, but received a " 
                      (type->string t))))]
  )
)

;;-----------------------------------------------------
;; TYPE IF OPERATOR
;; -----------------------------------------------------

(type-of-with-env-if : (Expr Expr Expr TEnv -> Type))
(define (type-of-with-env-if c a b env)
  (let ([ct (type-of-with-env c env)])
    (type-case Type ct
      [(t-bool)(mift ct a b env)]
      [else (raise-type-error 
        (string-append "In if, "
        (string-append "expected a boolean as condition, but received a " 
                        (type->string ct))))]
    )
  )
)

(mift : (Boolean Expr Expr TEnv -> Type))
(define (mift c a b env)
  (let ([at (type-of-with-env a env)]
        [bt (type-of-with-env b env)])
    (if (equal? at bt)
        at
        (raise-type-error 
        (string-append "In if, "
        (string-append "expected the two branches to return the same type, " 
        (string-append "but received " 
        (string-append (type->string at) 
        (string-append " and "
                       (type->string bt)))))))
    )
  )
)

;; -----------------------------------------------------
;; TYPE LAM OPERATOR
;; -----------------------------------------------------

(type-of-with-env-lam : (Symbol Type Expr TEnv -> Type))
(define (type-of-with-env-lam p t b env)
  (let* ([new-env (extendt env p t)]
         [bt (type-of-with-env b new-env)])
  (t-fun t bt))
)

;; -----------------------------------------------------
;; TYPE APP OPERATOR
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
            (raise-type-error
              (string-append "In app, "
              (string-append "expected actual argument type "
              (string-append "to be equal to the formal "
              (string-append "argument type, but received "
              (string-append  (type->string actual-argt)
                              (type->string formal-argt)
                              ))))))))]
    [else (raise-type-error 
      (string-append "In app, 
                      expected a function, but received a " 
                      (type->string fun-type)))]
  )
)

;; -----------------------------------------------------
;; NOTE: IS NOT NEEDED ANYMORE DUE TO DESUGARING
;; LET OPERATOR
;; -----------------------------------------------------

;; (type-of-with-env-let : (Symbol Expr Expr TEnv -> Type))
;; (define (type-of-with-env-let i v b env)
;;   (let* ([id-type (type-of-with-env v env)]
;;          [new-env (extend env i id-type)])
;;   (type-of-with-env b new-env))
;; )
;;

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






