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

(define (desugar [expr : Expr+]): Expr
  ; TODO: Implement me!
  ....)

(define (type-of [expr : Expr]) : Type
  ; TODO: Implement me!
  ....)
