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

(define (desugar [expr : Expr+]): Expr
  ; TODO: Implement me!
  ....)

(define (interp [expr : Expr]): Value
  ; TODO: Implement me!
  ....)
