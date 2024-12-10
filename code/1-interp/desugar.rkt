#lang plait

;; =============================================================================
;; Desugar: desugar.rkt
;; =============================================================================

(require "support.rkt" "desugar-support.rkt" "interpreter.rkt")

(define (eval [str : S-Exp]): Value
  (interp (desugar (parse+ str))))

;; DO NOT EDIT ABOVE THIS LINE =================================================

;; -----------------------------------------------------
;; MAIN
;; -----------------------------------------------------

(desugar : (Expr+ -> Expr))
(define (desugar expr)
  (type-case Expr+ expr
    [(e-num+    n)      (e-num        n)]
    [(e-str+    s)      (e-str        s)]
    [(e-bool+   b)      (e-bool       b)]
    [(e-var+    s)      (desugar-var  s)]
    [(e-lam+    s b)    (desugar-lam  s b)]
    [(e-app+    f a)    (desugar-app  f a)]
    [(sugar-and l r)    (desugar-and  l r)]
    [(sugar-or  l r)    (desugar-or   l r)]
    [(sugar-let s v b)  (desugar-let  s v b)]
    [(e-op+     p l r)  (desugar-op   p l r)]
    [(e-if+     f a b)  (desugar-if   f a b)]
  )
)

(desugar-var : (Symbol -> Expr))
(define (desugar-var s)
  (e-var s)
)

(desugar-op : (Operator Expr+ Expr+ -> Expr))
(define (desugar-op o l r)
  (let* ([new-l (desugar l)]
         [new-r (desugar r)])
  (e-op o new-l new-r))
)

(desugar-if : (Expr+ Expr+ Expr+ -> Expr))
(define (desugar-if c a b)
  (let* ([new-c (desugar c)]
         [new-a (desugar a)]
         [new-b (desugar b)])
  (e-if new-c new-a new-b))
)

(desugar-lam : (Symbol Expr+ -> Expr))
(define (desugar-lam s b)
  (let* ([new-b (desugar b)])
  (e-lam s new-b))
)

(desugar-app : (Expr+ Expr+ -> Expr))
(define (desugar-app f a)
  (let* ([new-f (desugar f)]
         [new-a (desugar a)])
  (e-app new-f new-a))
)

;; In `and` expressions, this means that if the first
;; argument of `and` evaluates to `false`, the second
;; argument to `and` is not evaluated and the `and` 
;; expression evaluates to `false`. 
(desugar-and : (Expr+ Expr+ -> Expr))
(define (desugar-and l r)
  (let* ([new-l (desugar l)]
         [new-r (desugar r)])
  (e-if new-l 
    (e-if new-r (e-bool #t) (e-bool #f)) 
    (e-bool #f)
  ))
)

;; (Similarly, if the first argument of `or` evaluates to
;; `true`, the second argument to `or` should not be
;; evaluated.) Thus, the second argument of a 
;; short-circuited expression should never throw an error.
(desugar-or : (Expr+ Expr+ -> Expr))
(define (desugar-or l r)
  (let* ([new-l (desugar l)]
         [new-r (desugar r)])
  (e-if new-l 
    (e-bool #t)
    (e-if new-r (e-bool #t) (e-bool #f))
  ))
)

(desugar-let : (Symbol Expr+ Expr+ -> Expr))
(define (desugar-let s v b)
  (let* ([new-v (desugar v)]
         [new-b (desugar b)])
  (e-app (e-lam s new-b) new-v)
  )
)

