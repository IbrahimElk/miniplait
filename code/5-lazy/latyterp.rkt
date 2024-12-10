#lang plait

;; =============================================================================
;; Lazy Typed Interpreter: latyterp.rkt
;; =============================================================================

(require "support.rkt"
         (rename-in (typed-in "err-support.rkt"
                              [raise-type-error : (String -> 'a)]
                              [raise-interp-error : (String -> 'b)])))

(define (eval [str : S-Exp]): Value
  (let* ([expr (desugar (parse str))]
         [t (type-of expr)])
    (strictFull (interp expr))))

;; -----------------------------------------------------
;; -----------------------------------------------------
;; -----------------------------------------------------
;; -----------------------------------------------------

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
;; LAZY HELP FUNCTIONS 
;; -----------------------------------------------------

;; NOTE
;; (README)
;; The "top-level" `eval` should force its result to be evaluated 
;; (so it can show the end-user an answer, rather than a suspended computation).
(strictFull : (Value -> Value))
(define (strictFull v)
  (type-case Value v
    [(v-num  n)       (v-num  n)]
    [(v-bool v)       (v-bool v)]
    [(v-str  v)       (v-str  v)]
    [(v-fun p b e)    (v-fun p b e)]
    [(v-list h t)     (v-list (strictFull h) (strictFull t))]
    [(v-empty)        (v-empty)]
    [(v-susp b e)     (strictFull (interp-with-env b e))]
  )
)

;; NOTE
;; (README)
;; the returned Value is guaranteed to not be a v-susp.
;; Makes forced evaluations be shallow because you don't 
;; make sure that there won't be a v-susp inside the 
;; elements of a list etc.
(strict : (Value -> Value))
(define (strict v)
  (type-case Value v
    [(v-num  n)       (v-num  n)]
    [(v-bool v)       (v-bool v)]
    [(v-str  v)       (v-str  v)]
    [(v-fun p b e)    (v-fun p b e)]
    [(v-list h t)     (v-list h t)]
    [(v-empty)        (v-empty)]
    [(v-susp b e)     (strict (interp-with-env b e))]
  )
)


;; -----------------------------------------------------
;; ENV FUNCTIONS
;; -----------------------------------------------------

(define empty-env (hash empty))

(lookup : (Env Symbol -> Value))
(define (lookup env s)
  (let ([x (hash-ref env s)])
    (unbox (some-v x)))
)

(extend : (Env Symbol (Boxof Value) -> Env))
(define (extend old-env new-name value)
  (hash-set old-env new-name value))

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
    [(sugar-rec s v t b)  (desugar-rec  s v t b)]
  )
)

(define (type-of [expr : Expr]): Type
  (type-of-with-env expr empty-envt)
)

(type-of-with-env : (Expr TEnv -> Type))
(define (type-of-with-env expr env)
  (type-case Expr expr
    [(e-num   n       )  (t-num  )]
    [(e-bool  b       )  (t-bool )]
    [(e-str   s       )  (t-str  )]
    [(e-var   n       )  (type-of-with-env-var  n        env)]
    [(e-empty t       )  (type-of-with-env-emp  t        env)]
    [(e-un-op op e    )  (type-of-with-env-uop  op e     env)]
    [(e-app   f  a    )  (type-of-with-env-app  f  a     env)]
    [(e-if    c  a b  )  (type-of-with-env-if   c  a b   env)]
    [(e-lam   p  t b  )  (type-of-with-env-lam  p  t b   env)]
    [(e-op    op l r  )  (type-of-with-env-op   op l r   env)]
    [(e-rec   s  v t b)  (type-of-with-env-rec  s  t v b env)]
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
    [(e-empty t)        (v-empty)]
    [(e-lam p t b)      (v-fun p b env)]
    [(e-var v)          (lookup env v)]
    [(e-op op l r)      (interp-with-env-op  op l r env)]
    [(e-un-op op e)     (interp-with-env-uop op e   env)]
    [(e-if c a b)       (interp-with-env-if  c a b env)]
    [(e-app f a)        (interp-with-env-app f a env)]
    [(e-rec s v t b)    (interp-with-env-rec s v b env)]
  )
)

;; -----------------------------------------------------
;; -----------------------------------------------------
;;  INTERPRETER 
;; -----------------------------------------------------
;; -----------------------------------------------------

;; -----------------------------------------------------
;; INTERP OP OPERATOR
;; -----------------------------------------------------

;; type of any binary operator
(define-type-alias BinOpS (Value Value    -> Value))
(define-type-alias BinOpL (Expr  Expr Env -> Value))

(interp-with-env-op : (Operator Expr Expr Env -> Value))
(define (interp-with-env-op o l r env)
  (type-case Operator o
    [(op-plus)    (so madd l r env)]
    [(op-append)  (so mapp l r env)] 
    [(op-str-eq)  (so mstr l r env)]
    [(op-num-eq)  (so mnum l r env)]
    [(op-link)    (lo mlin l r env)]))

;; strict operators (SO)
;; these operators force all their arguments to be evaluated.
(so : (BinOpS Expr Expr Env -> Value))
(define (so o l r env)
  (let ([vl (strict (interp-with-env l env))]
        [vr (strict (interp-with-env r env))])
      (o vl vr)))

;; lazy operators (LO)
(lo : (BinOpL Expr Expr Env -> Value))
(define (lo o l r env)
      (o l r env))

(madd : BinOpS)
(define (madd l r)
  (v-num (+ (v-num-value l) (v-num-value r))))

(mapp : BinOpS)
(define (mapp l r)
  (v-str (string-append (v-str-value l) (v-str-value r))))

(mstr : BinOpS)
(define (mstr l r)
  (v-bool (string=? (v-str-value l) (v-str-value r))))

(mnum : BinOpS)
(define (mnum l r)
  (v-bool (= (v-num-value l) (v-num-value r))))

(mlin : BinOpL)
(define (mlin l r env)
  (v-list (v-susp l env) (v-susp r env)))

;;-----------------------------------------------------
;; INTERP UOP OPERATOR
;; -----------------------------------------------------

(interp-with-env-uop : (UnaryOperator Expr Env -> Value))
(define (interp-with-env-uop uop e env)
  (type-case UnaryOperator uop
    [(op-first)     (mfirst    e env)]
    [(op-rest)      (mrest     e env)] 
    [(op-is-empty)  (mis-empty e env)])
)

(mfirst : (Expr Env -> Value))
(define (mfirst e env)
  (let  ([v   (strict (interp-with-env e env))])
    (cond
      [(v-list?  v)  (mfirst-list v)]
      [(v-empty? v)  (raise-interp-error 
                      (string-append "In op-first, "
                      (string-append "expected a non empty list as argument, "
                                     "but received an empty list")))])
  )
)

(mfirst-list : (Value -> Value))
(define (mfirst-list v)
  (let ([new-l (v-list-head v)]) ;; Don't need to strict eval head
      new-l)
)

(mrest : (Expr Env -> Value))
(define (mrest e env)
  (let  ([v   (strict (interp-with-env e env))])
    (cond
      [(v-list?  v)  (v-list-tail v)]
      [(v-empty? v)  (raise-interp-error 
                      (string-append "In op-rest, "
                      (string-append "expected a non empty list as argument, "
                                     "but received an empty list")))])
  )
)

(mis-empty : (Expr Env -> Value))
(define (mis-empty e env)
  (let  ([v   (strict (interp-with-env e env))])
    (cond
      [(v-list?  v)  (mist-empty-list v)]
      [(v-empty? v)  (v-bool #t)])
  )
)

(mist-empty-list : (Value -> Value))
(define (mist-empty-list v)
  (let ([new-l (strict (v-list-head v))]) ;; strict eval of head of list
    (v-bool (equal? new-l (v-empty)))
  )
)

;;-----------------------------------------------------
;; INTERP IF OPERATOR
;; -----------------------------------------------------

(interp-with-env-if : (Expr Expr Expr Env -> Value))
(define (interp-with-env-if c a b env)
  (let* ([cv  (strict (interp-with-env c env))]
         [cbv (v-bool-value cv)])
    (mif cbv a b env)
  )
)

(mif : (Boolean Expr Expr Env -> Value))
(define (mif c a b env)
  (if c 
    (interp-with-env a env)
    (interp-with-env b env))
)

;; -----------------------------------------------------
;; INTERP APP OPERATOR
;; -----------------------------------------------------

(interp-with-env-app : (Expr Expr Env -> Value))
(define (interp-with-env-app f arg env)
  (let ([fun-val (strict (interp-with-env f env))])
    (mapply fun-val arg env)))

(mapply : (Value Expr Env -> Value))
(define (mapply fun-val arg env)
  (let* ([p (v-fun-param fun-val)]
         [b (v-fun-body fun-val)]
         [fun-env (v-fun-env fun-val)]
         [arg-val (v-susp arg env)]
         [new-env (extend fun-env p (box arg-val))])
    (interp-with-env b new-env))
)

;; -----------------------------------------------------
;; INTERP REC OPERATOR
;; -----------------------------------------------------

;; NOTE
;; (Ibrahim)
;; pass argument `varval` by reference 
;; to the functions extend & update !!

(interp-with-env-rec : (Symbol Expr Expr Env -> Value))
(define (interp-with-env-rec var val body env)
    (let* ([var-val (box (v-susp val env))]
           [new-env (extend env var var-val)])
      (begin
        (set-box! var-val (v-susp val new-env))
        (interp-with-env body new-env))
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
;; TYPE REC OPERATOR
;; -----------------------------------------------------

(type-of-with-env-rec : (Symbol Type Expr Expr TEnv -> Type))
(define (type-of-with-env-rec var t val body env)
  (let* ([new-env (extendt env var t)]
         [fun-type (type-of-with-env body new-env)])
      (mrect fun-type t var val env)
  )
)

(mrect : (Type Type Symbol Expr TEnv -> Type))
(define (mrect bodyt t var val env)
  (let*  ([new-env (extendt env var t)]
          [actualt (type-of-with-env val new-env)])
    (if (equal? actualt t)
        bodyt
        (raise-type-error
          (string-append "In rec, actual argument type actual argument type "
                         "is not equal to the formal argument type"))))
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

;; -----------------------------------------------------
;; DESUGAR REC OPERATOR 
;; -----------------------------------------------------

(desugar-let : (Symbol Expr+ Type Expr+ -> Expr))
(define (desugar-rec s v t b)
  (let* ([new-v (desugar v)]
         [new-b (desugar b)])
    (e-rec s new-v t new-b)
  )
)

