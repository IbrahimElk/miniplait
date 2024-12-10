#lang racket

;; =============================================================================
;; Desugar: desugar-tests.rkt
;; =============================================================================

(require (only-in "desugar.rkt" eval)
         "support.rkt"
         "desugar-support.rkt"
         "test-support.rkt")

;; DO NOT EDIT ABOVE THIS LINE =================================================

(define/provide-test-suite student-tests ;; DO NOT EDIT THIS LINE ==========

  ;; INFO:
  ;; BASIC

  (test-raises-error? "var-0" (eval `x))

  (test-equal? "num-1"
               (eval `2) (v-num 2))
  
  (test-equal? "str-2"
               (eval `"hello") (v-str "hello"))

  (test-equal? "bool-3"
               (eval `true) (v-bool #t))

  (test-equal? "bool-4"
               (eval `false) (v-bool #f))

  (test-true   "lam-5"
               (v-fun? (eval `{lam x 5})))

  ;; INFO:
  ;; BINARY OPERATIONS
  ;; ADDITION

  (test-raises-error? "op-plus-0"
               (eval `{+ 3 "5"}))

  (test-raises-error? "op-plus-1"
               (eval `{+ 3 true}))
  
  (test-raises-error? "op-plus-2"
               (eval `{+ 3 {lam x x}}))
  
  (test-raises-error? "op-plus-3"
               (eval `{+ 3 {empty}}))

  (test-raises-error? "op-plus-4"
               (eval `{+ "5" 3 }))

  (test-raises-error? "op-plus-5"
               (eval `{+ true 3}))
  
  (test-raises-error? "op-plus-6"
               (eval `{+ {lam x x} 3}))
  
  (test-raises-error? "op-plus-7"
               (eval `{+ {empty} 3}))

  (test-raises-error? "op-plus-8"
               (eval `{+ "3" 5}))
  
  (test-equal? "op-plus-9"
               (eval `{+ 3 5})
               (v-num 8))

  (test-equal? "op-plus-10"
               (eval `{+ 1 {+ 2 3}}) 
               (v-num 6))
  
  (test-equal? "op-plus-11"
               (eval `{+ {+ 1 2} 3}) 
               (v-num 6))

  (test-equal? "op-plus-12"
               (eval `{+ 1 {+ {+ 2 3} 4}}) 
               (v-num 10))

  ;; INFO:
  ;; APPENDING

  (test-raises-error? "op-append-0"
               (eval `{++ "3" 5}))

  (test-raises-error? "op-append-1"
               (eval `{++ "3" true}))
  
  (test-raises-error? "op-append-2"
               (eval `{++ "3" {lam x x}}))

  (test-raises-error? "op-append-3"
               (eval `{++ "3" {empty}}))

  (test-raises-error? "op-append-4"
               (eval `{++ 5 "3" }))

  (test-raises-error? "op-append-5"
               (eval `{++ true "3"}))
  
  (test-raises-error? "op-append-6"
               (eval `{++ {lam x x} "3"}))

  (test-raises-error? "op-append-7"
               (eval `{++ {empty} "3"}))
  
  (test-equal? "op-append-8"
               (eval `{++ "3" "5"})
               (v-str "35"))

  (test-equal? "op-append-9"
               (eval `{++ "hello" {++ " " "world"}}) 
               (v-str "hello world"))
  

  ;; INFO:
  ;; STRING-EQUAL?

  (test-raises-error? "op-streq-0"
               (eval `{str= "3" 5}))
  
  (test-raises-error? "op-streq-1"
               (eval `{str= "3" true}))
  
  (test-raises-error? "op-streq-2"
               (eval `{str= "3" {lam x x}}))
  
  (test-raises-error? "op-streq-3"
               (eval `{str= "3" {empty}}))
  
  (test-raises-error? "op-streq-4"
               (eval `{str= 5 "3"}))
  
  (test-raises-error? "op-streq-5"
               (eval `{str= true "3"}))
  
  (test-raises-error? "op-streq-6"
               (eval `{str= {lam x x} "3"}))
  
  (test-raises-error? "op-streq-7"
               (eval `{str= {empty} "3"}))

  (test-equal? "op-streq-8"
               (eval `{str= "3" "5"})
               (v-bool #f))

  (test-equal? "op-streq-9"
               (eval `{str= "3" "3"})
               (v-bool #t))

  ;; INFO:
  ;; NUMBER-EQUAL? 

  (test-raises-error? "op-numeq-0"
               (eval `{num= 3 "5"}))
  
  (test-raises-error? "op-numeq-1"
               (eval `{num= 3 true}))
  
  (test-raises-error? "op-numeq-2"
               (eval `{num= 3 {lam x x}}))
  
  (test-raises-error? "op-numeq-3"
               (eval `{num= 3 {empty}}))
  
  (test-raises-error? "op-numeq-4"
               (eval `{num= "5" 3}))
  
  (test-raises-error? "op-numeq-5"
               (eval `{num= true 3}))
  
  (test-raises-error? "op-numeq-6"
               (eval `{num= {lam x x} 3}))
  
  (test-raises-error? "op-numeq-7"
               (eval `{num= {empty} 3}))

  (test-equal? "op-numeq-8"
               (eval `{num= 3 5})
               (v-bool #f))

  (test-equal? "op-numeq-9"
               (eval `{num= 3 3})
               (v-bool #t))

  ;; INFO:
  ;; IF STATEMENT 

  ;; condition needs to be boolean
  (test-raises-error? "if-0"
               (eval `{if 5 5 5}))
                
  ;; branches of if need to be of same type
  ;; NOTE: not the case when we have only the interpreter 
  (test-equal? "if-1"
               (eval `{if false 5 false})
               (v-bool #f))
                 
  ;; branches of if need to be of same type
  ;; NOTE: not the case when we have only the interpreter 
  (test-true   "if-2"
               (v-fun? 
                 (eval `{if false 
                        {lam a 5 }
                        {lam y "5"}})))
  
  ;; branches of if need to be of same type
  ;; NOTE: not the case when we have only the interpreter 
  (test-equal? "if-4"
               (eval `{if true false "5"})
               (v-bool #f))

  (test-equal? "if-5"
               (eval `{if true 3 5})
               (v-num 3))

  (test-equal? "if-6"
               (eval `{if false 3 5})
               (v-num 5))
  
  (test-equal? "if-7"
               (eval `{if true "3" "5"})
               (v-str "3"))

  (test-equal? "if-8"
               (eval `{if true false true})
               (v-bool #f))

  (test-true "if-9"
               (v-fun? (eval `{if true 
                        {lam a 5} 
                        {lam y 1}})))

  ;; short-circuit
  (test-equal? "and-11"
               (eval `{if true "short" {+ 5 "error skibidi"}})
               (v-str "short"))

  ;; short-circuit
  (test-equal? "and-12"
               (eval `{if false {+ 5 "error skibidi"} "short"})
               (v-str "short"))

  ;; INFO:
  ;; LAM STATEMENT 
  
  (test-true "lam-0"
               (v-fun?
                 (eval `{lam a a})))
  
  ;; INFO:
  ;; APP STATEMENT 
  
  (test-raises-error? "app-01"
               (eval `{5 5}))
  
  (test-raises-error? "app-02"
               (eval `{"5" 5}))
  
  (test-raises-error? "app-03"
               (eval `{false 5}))
  
  (test-raises-error? "app-04"
               (eval `{{empty} 5}))

  (test-raises-error? "app-05"
               (eval `{f 5}))

  (test-raises-error? "app-06"
               (eval `{{lam x y} 1}))

  ;; scoping 
  (test-raises-error? "app-07"
               (eval `{+ {{lam x x} 1}  x}))

  ;; shadowing
  (test-equal? "app-1"
               (eval `{{lam x 
                        {{lam x 
                          x} 3}} 5}) 
               (v-num 3))

  (test-equal? "app-4"
               (eval `{{lam a a} 5})
               (v-num 5))

  ;; `{let {x 1} {+ {let {x 2}   x}  x}}    => 3
  (test-equal? "app-5"
               (eval `{{lam x 
                       {+ {{lam x x} 2} x}} 
                       1}) 
               (v-num 3))
  
  (test-equal? "app-6"
               (eval `{{lam x {+ x x}} 1})
               (v-num 2))
  
  (test-equal? "app-7"
               (eval `{{{lam x 
                        {lam y
                        {+ x y}}} 3} 4}) 
               (v-num 7))

  ;; `{{lam f {f 3}} {lambda x {+ x x}}}  => 6 
  (test-equal? "app-8"
               (eval `{{lam  f {f 3}} 
                       {lam  x {+ x x}}}) 
    (v-num 6))

  ;; `{let1 {x 1}
  ;;        {let1 {f {lambda y x}}
  ;;              {let1 {x 2}
  ;;                    {f 10}}}}
  ;; `{{\x -> {{\f -> {{\x -> {f 10}} 2}}{lam y x}}}1}
  (test-equal? "app-9"
    (eval `{{lam x  {{lam f
           {{lam x  {f 10}} 2}} {lam y x}}} 1}) 
    (v-num 1))

  ;; `{{let1 {x 3}
  ;;         {lambda y {+ x y}}}
  ;;   4}
  ;; `{{{\x -> {\y -> {+ x y}}}3}4}
  (test-equal? "app-10"
    (eval `{{{lam x {lam y {+ x y}}}3}4}) 
           (v-num 7))

  ;; ((let ([y 3])
  ;;    (lambda (y) (+ y 1)))
  ;;  5)
  (test-equal? "app-11"
    (eval `{{{lam y {lam y {+ y 1}}} 3} 5}) 
           (v-num 6))
  
  ;; (deffun (f x)
  ;;    (lambda (y) (+ x y)))
  ;; (defvar x 0)
  ;; ((f 2) 1)
  (test-equal? "app-12"
    (eval `{{{{ lam x 
          {lam x 
          {lam y 
          {+ x y}}}} 0} 2} 1}) (v-num 3))

  ;; INFO:
  ;; AND STATEMENT 

  (test-raises-error? "and-01" (eval `{and 5                  true}))
  (test-raises-error? "and-02" (eval `{and "str"              true}))
  (test-raises-error? "and-03" (eval `{and {lam a a}          true}))

  (test-raises-error? "and-05" (eval `{and true 5                }))
  (test-raises-error? "and-06" (eval `{and true "str"            }))
  (test-raises-error? "and-07" (eval `{and true {lam a a}        }))

  (test-equal? "and-1"
               (eval `{and true true}) (v-bool #t))

  (test-equal? "and-2"
               (eval `{and true false}) (v-bool #f))

  (test-equal? "and-3"
               (eval `{and false true}) (v-bool #f))

  (test-equal? "and-4"
               (eval `{and false false}) (v-bool #f))

  (test-equal? "and-5"
               (eval `{and {and true true} true}) (v-bool #t))

  ;; short-circuit
  (test-equal? "and-06" (eval `{and false 5                }) (v-bool #f))
  (test-equal? "and-07" (eval `{and false "str"            }) (v-bool #f))
  (test-equal? "and-08" (eval `{and false {lam a a}        }) (v-bool #f))

  ;; INFO:
  ;; OR STATEMENT 

  (test-raises-error? "or-01" (eval `{or 5                 false}))
  (test-raises-error? "or-02" (eval `{or "str"             false}))
  (test-raises-error? "or-03" (eval `{or {lam a a}         false}))

  (test-raises-error? "or-05" (eval `{or false 5                }))
  (test-raises-error? "or-06" (eval `{or false "str"            }))
  (test-raises-error? "or-07" (eval `{or false {lam a a}        }))

  (test-equal? "or-1"
               (eval `{or true true}) (v-bool #t))

  (test-equal? "or-2"
               (eval `{or true false}) (v-bool #t))

  (test-equal? "or-3"
               (eval `{or false true}) (v-bool #t))

  (test-equal? "or-4"
               (eval `{or false false}) (v-bool #f))

  (test-equal? "or-5"
               (eval `{or {or false true} false}) (v-bool #t))

  ;; short-circuit
  (test-equal? "and-06" (eval `{or true 5         }) (v-bool #t))
  (test-equal? "and-07" (eval `{or true "str"     }) (v-bool #t))
  (test-equal? "and-08" (eval `{or true {lam a a} }) (v-bool #t))

  ;; INFO:
  ;; LET STATEMENT 

  (test-raises-error? "let-0" (eval `{let {3 5} x}))

  (test-raises-error? "let-1"
               (eval `{let {x "foo"} {+ x 1}}))

  (test-equal? "let-2"
               (eval `{let {x 5} x}) 
               (v-num 5))

  (test-equal? "let-3"
               (eval `{let {x 5} 
                      {let {y {+ x 2}} 
                      {+ x y}}}) 
               (v-num 12))

  ;; shadowing
  (test-equal? "let-4"
               (eval `{let {x 5} 
                      {let {x 3} x}}) 
               (v-num 3))

  ;; recursive definition
  ;; let x = \y -> x y
  (test-raises-error? "let-5"
               (eval `{let {x {lam y {x y}}}
                           {x 5}}))

)


;; DO NOT EDIT BELOW THIS LINE =================================================

(module+ main (run-tests student-tests))
