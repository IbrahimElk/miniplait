#lang plait

;; =============================================================================
;; Type Checker: type-checker.rkt
;; =============================================================================

(require "support.rkt")

(define (type-check [str : S-Exp]): Type
  (type-of (parse str)))

;; DO NOT EDIT ABOVE THIS LINE =================================================

(define (type-of [expr : Expr]): Type
  ; TODO: Implement me!
  ....)
