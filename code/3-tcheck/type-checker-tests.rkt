#lang racket

;; =============================================================================
;; Type Checker: type-checker-tests.rkt
;; =============================================================================

(require (only-in "type-checker.rkt" type-check)
         "support.rkt"
         "test-support.rkt")

;; DO NOT EDIT ABOVE THIS LINE =================================================

(define/provide-test-suite student-tests ;; DO NOT EDIT THIS LINE =========

  ;; NOTE: Ibrahim
  ;; weird how the let statement doesn't have any type annotations.
  ;; why in part 4, was that necessary ? don't remember

  ;; INFO:
  ;; BASIC

  (test-raises-error? "var-0" (type-check `x))

  (test-equal? "num-1"
               (type-check `2) (t-num))
  
  (test-equal? "str-2"
               (type-check `"hello") (t-str))

  (test-equal? "bool-3"
               (type-check `true) (t-bool))

  (test-equal? "bool-4"
               (type-check `false) (t-bool))

  (test-equal? "lam-5"
               (type-check `{lam {x : Num} 5})
               (t-fun (t-num) (t-num)))

  (test-equal? "list-6"
               (type-check `{empty : Str})
               (t-list (t-str)))

  ;; INFO:
  ;; BINARY OPERATIONS
  ;; ADDITION

  (test-raises-error? "op-plus-0"
               (type-check `{+ 3 "5"}))

  (test-raises-error? "op-plus-1"
               (type-check `{+ 3 true}))
  
  (test-raises-error? "op-plus-2"
               (type-check `{+ 3 {lam {x : Num} x}}))
  
  (test-raises-error? "op-plus-3"
               (type-check `{+ 3 {empty : Num}}))

  (test-raises-error? "op-plus-4"
               (type-check `{+ "5" 3 }))

  (test-raises-error? "op-plus-5"
               (type-check `{+ true 3}))
  
  (test-raises-error? "op-plus-6"
               (type-check `{+ {lam {x : Num} x} 3}))
  
  (test-raises-error? "op-plus-7"
               (type-check `{+ {empty : Num} 3}))

  (test-raises-error? "op-plus-8"
               (type-check `{+ "3" 5}))
  
  (test-equal? "op-plus-9"
               (type-check `{+ 3 5})
               (t-num))

  (test-equal? "op-plus-10"
               (type-check `{+ 1 {+ 2 3}}) 
               (t-num))
  
  (test-equal? "op-plus-11"
               (type-check `{+ {+ 1 2} 3}) 
               (t-num))

  (test-equal? "op-plus-12"
               (type-check `{+ 1 {+ {+ 2 3} 4}}) 
               (t-num))

  ;; INFO:
  ;; APPENDING

  (test-raises-error? "op-append-0"
               (type-check `{++ "3" 5}))

  (test-raises-error? "op-append-1"
               (type-check `{++ "3" true}))
  
  (test-raises-error? "op-append-2"
               (type-check `{++ "3" {lam {x : Num} x}}))

  (test-raises-error? "op-append-3"
               (type-check `{++ "3" {empty : Num}}))

  (test-raises-error? "op-append-4"
               (type-check `{++ 5 "3" }))

  (test-raises-error? "op-append-5"
               (type-check `{++ true "3"}))
  
  (test-raises-error? "op-append-6"
               (type-check `{++ {lam {x : Num} x} "3"}))

  (test-raises-error? "op-append-7"
               (type-check `{++ {empty : Num} "3"}))
  
  (test-equal? "op-append-8"
               (type-check `{++ "3" "5"})
               (t-str))

  (test-equal? "op-append-9"
               (type-check `{++ "hello" {++ " " "world"}}) 
               (t-str))
  
  ;; INFO:
  ;; STRING-EQUAL?

  (test-raises-error? "op-streq-0"
               (type-check `{str= "3" 5}))
  
  (test-raises-error? "op-streq-1"
               (type-check `{str= "3" true}))
  
  (test-raises-error? "op-streq-2"
               (type-check `{str= "3" {lam {x : Num} x}}))
  
  (test-raises-error? "op-streq-3"
               (type-check `{str= "3" {empty : Num}}))
  
  (test-raises-error? "op-streq-4"
               (type-check `{str= 5 "3"}))
  
  (test-raises-error? "op-streq-5"
               (type-check `{str= true "3"}))
  
  (test-raises-error? "op-streq-6"
               (type-check `{str= {lam {x : Num} x} "3"}))
  
  (test-raises-error? "op-streq-7"
               (type-check `{str= {empty : Num} "3"}))

  (test-equal? "op-streq-8"
               (type-check `{str= "3" "5"})
               (t-bool))

  (test-equal? "op-streq-9"
               (type-check `{str= "3" "3"})
               (t-bool))

  ;; INFO:
  ;; NUMBER-EQUAL? 

  (test-raises-error? "op-numeq-0"
               (type-check `{num= 3 "5"}))
  
  (test-raises-error? "op-numeq-1"
               (type-check `{num= 3 true}))
  
  (test-raises-error? "op-numeq-2"
               (type-check `{num= 3 {lam {x : Num} x}}))
  
  (test-raises-error? "op-numeq-3"
               (type-check `{num= 3 {empty : Num}}))
  
  (test-raises-error? "op-numeq-4"
               (type-check `{num= "5" 3}))
  
  (test-raises-error? "op-numeq-5"
               (type-check `{num= true 3}))
  
  (test-raises-error? "op-numeq-6"
               (type-check `{num= {lam {x : Num} x} 3}))
  
  (test-raises-error? "op-numeq-7"
               (type-check `{num= {empty : Num} 3}))

  (test-equal? "op-numeq-8"
               (type-check `{num= 3 5})
               (t-bool))
  
  (test-equal? "op-numeq-9"
               (type-check `{num= 3 3})
               (t-bool))

  ;; INFO:
  ;; LINK 

  ;; element to be added must have same type as list
  (test-raises-error? "op-link-0"
               (type-check `{link 3 {empty : Bool}}))

  (test-raises-error? "op-link-1"
               (type-check `{link "3" {empty : Bool}}))
  
  (test-raises-error? "op-link-2"
               (type-check `{link true {empty : Num}}))
  
  (test-raises-error? "op-link-3"
               (type-check `{link {lam {x : Num} x} {empty : Bool}}))
  
  (test-raises-error? "op-link-4"
               (type-check `{link {empty : Num} {empty : Bool}}))
  
  ;; expected a list for the second argument
  (test-raises-error? "op-link-5"
               (type-check `{link "3" 5}))

  (test-raises-error? "op-link-6"
               (type-check `{link "3" "5"}))
  
  (test-raises-error? "op-link-7"
               (type-check `{link "3" true}))
  
  (test-raises-error? "op-link-8"
               (type-check `{link "3" {lam {x : Num} x}}))

  ;; add element to list correctly
  (test-equal? "op-link-9"
               (type-check `{link  3 {empty : Num}})
               (t-list (t-num)))

  (test-equal? "op-link-10"
               (type-check `{link  "3" {empty : Str}})
               (t-list (t-str)))

  (test-equal? "op-link-11"
               (type-check `{link  true {empty : Bool}})
               (t-list (t-bool)))
  
  (test-equal? "op-link-12"
               (type-check `{link  {empty : Bool} {empty : {List Bool}}})
               (t-list (t-list (t-bool))))

  (test-equal? "op-link-13"
               (type-check `{link  {lam {x : Num} x} {empty : {Num -> Num}}})
               (t-list (t-fun (t-num) (t-num))))
  
  (test-equal? "op-link-14"
               (type-check `{link  3 {link  3 {empty : Num}}})
               (t-list (t-num)))

  ;; INFO:
  ;; UNARY OPERATIONS
  ;; FIRST

  ;; first can only applied to lists
  (test-raises-error? "uop-first-O"
               (type-check `{first 5}))

  ;; NOTE Ibrahim
  ;; first can only applied to non empty lists,
  ;; type-checker cannot distinguish between empty and 
  ;; non-empty lists. As far as the type-checker is 
  ;; concerned, this is a valid operation.
  (test-equal? "uop-first-1"
               (type-check `{first {empty : Num}})
               (t-num))
  
  ;; the type of the first element of an empty list is the type
  ;; of the list element
  (test-equal? "uop-first-2"
               (type-check `{first {link 1 {empty : Num}}})
               (t-num))

  (test-equal? "uop-first-3"
               (type-check `{first {link false {empty : Bool}}})
               (t-bool))

  (test-equal? "uop-first-4"
               (type-check `{first {link "f" {empty : Str}}})
               (t-str))
   
  (test-equal? "uop-first-5"
               (type-check `{first {link {lam {x : Num} 5} 
                                     {empty : {Num -> Num}}}})
               (t-fun (t-num) (t-num)))

  (test-equal? "uop-first-6"
               (type-check 
                 `{first {link {empty : Bool} {empty : {List Bool}}}})
               (t-list (t-bool)))

  ;; INFO:
  ;; REST 

  ;; rest can only be applied to lists
  (test-raises-error? "uop-rest-O"
               (type-check `{rest 5}))

  ;; NOTE Ibrahim
  ;; rest can only be applied to non empty lists,
  ;; type-checker cannot distinguish between empty and 
  ;; non-empty lists. As far as the type-checker is 
  ;; concerned, this is a valid operation.
  (test-equal? "uop-rest-1"
               (type-check `{rest {empty : Num}})
               (t-list (t-num)))

  ;; the type of the rest of the list of an empty list is the type
  ;; of the list itself
  (test-equal? "uop-rest-2"
               (type-check `{rest {link 1 {empty : Num}}})
               (t-list (t-num)))

  (test-equal? "uop-rest-3"
               (type-check `{rest {link false {empty : Bool}}})
               (t-list (t-bool)))

  (test-equal? "uop-rest-4"
               (type-check `{rest {link "f" {empty : Str}}})
               (t-list (t-str)))
   
  (test-equal? "uop-rest-5"
               (type-check `{rest {link {lam {x : Num} 5} 
                                  {empty : {Num -> Num}}}})
               (t-list (t-fun (t-num) (t-num))))

  (test-equal? "uop-rest-6"
               (type-check `{rest {link {empty : Bool} 
                                  {empty : {List Bool}}}})
               (t-list (t-list (t-bool))))

  ;; INFO:
  ;; IS-EMPTY?

  (test-raises-error? "isempty-0"
               (type-check `{is-empty 5}))

  (test-equal? "uop-isempty-1"
               (type-check `{is-empty {empty : Num}})
               (t-bool))

  (test-equal? "uop-isempty-2"
               (type-check `{is-empty {empty : Bool}})
               (t-bool))

  (test-equal? "uop-isempty-3"
               (type-check `{is-empty {empty : Str}})
               (t-bool))

  (test-equal? "uop-isempty-4"
               (type-check `{is-empty {empty : {Num -> Num}}})
               (t-bool))

  (test-equal? "uop-isempty-5"
               (type-check `{is-empty {empty : {List Num}}})
               (t-bool))

  (test-equal? "uop-isempty-6"
               (type-check `{is-empty {empty : {List Num}}})
               (t-bool))

  (test-equal? "uop-isempty-7"
               (type-check `{is-empty {link 1 {empty : Num}}})
               (t-bool))

  (test-equal? "uop-isempty-8"
               (type-check `{is-empty {link false {empty : Bool}}})
               (t-bool))
  
  (test-equal? "uop-isempty-9"
               (type-check `{is-empty {link "f" {empty : Str}}})
               (t-bool))
  
  (test-equal? "uop-isempty-10"
               (type-check `{is-empty {link {lam {x : Num} 5} 
                                {empty : {Num -> Num}}}})
               (t-bool))
  
  (test-equal? "uop-isempty-11"
               (type-check `{is-empty {link {empty : Bool} 
                                {empty : {List Bool}}}})
               (t-bool))

  ;; INFO:
  ;; IF STATEMENT 

  ;; condition needs to be boolean
  (test-raises-error? "if-0"
               (type-check `{if 5 5 5}))
                
  ;; branches of if need to be of same type
  (test-raises-error? "if-1"
               (type-check `{if false 5 false}))
                 
  ;; branches of if need to be of same type
  (test-raises-error? "if-2"
               (type-check `{if false 
                        {lam {a : Num} 5 }
                        {lam {y : Num} "5"}}))
  
  ;; branches of if need to be of same type
  (test-raises-error? "if-3"
               (type-check `{if false
                   {empty : Num} 
                   {empty : Str}}))
  
  ;; branches of if need to be of same type
  (test-raises-error? "if-4"
               (type-check `{if true false "5"}))

  (test-equal? "if-5"
               (type-check `{if true 3 5})
               (t-num))

  (test-equal? "if-6"
               (type-check `{if false 3 5})
               (t-num))
  
  (test-equal? "if-7"
               (type-check `{if true "3" "5"})
               (t-str))

  (test-equal? "if-8"
               (type-check `{if true false true})
               (t-bool))

  (test-equal? "if-9"
               (type-check `{if true 
                        {lam {a : Num} 5} 
                        {lam {y : Num} 1}})
               (t-fun (t-num) (t-num)))

  (test-equal? "if-10"
               (type-check `{if true 
                   {empty : Num} 
                   {link 1 {empty : Num}}})
               (t-list (t-num)))

  ;; short-circuit  
  ;; NOTE: not possible when we have type-checker
  (test-raises-error? "and-11"
               (type-check `{if true "short" {+ 5 "error skibidi"}}))

  ;; short-circuit
  ;; NOTE: not possible when we have type-checker
  (test-raises-error? "and-12"
               (type-check `{if false {+ 5 "error skibidi"} "short"}))
  
  ;; INFO:
  ;; LAM STATEMENT 
  
  (test-equal? "lam-0"
               (type-check `{lam {a : Num} a})
               (t-fun (t-num) (t-num)))

  ;; INFO:
  ;; APP STATEMENT 
  
  (test-raises-error? "app-01"
               (type-check `{5 5}))
  
  (test-raises-error? "app-02"
               (type-check `{"5" 5}))
  
  (test-raises-error? "app-03"
               (type-check `{false 5}))
  
  (test-raises-error? "app-04"
               (type-check `{{empty : Num} 5}))

  (test-raises-error? "app-05"
               (type-check `{f 5}))
  
  (test-raises-error? "app-06"
               (type-check `{{lam {x : Num} y} 1}))
  
  ;; scoping 
  (test-raises-error? "app-07"
               (type-check `{+ {{lam {x : Num} x} 1}  x}))

  (test-raises-error? "app-08"
               (type-check `{{lam {a : Num} a} "5"}))
  
  ;; identifier shadowing
  (test-equal? "app-1"
               (type-check `{lam {x : Num} 
                              {lam {x : Str} 
                                x}}) 
               (t-fun (t-num) (t-fun (t-str) (t-str))))
  
  (test-equal? "app-4"
               (type-check `{{lam {a : Num} a} 5})
               (t-num))

  ;; `{let {x 1} {+ {let {x 2}   x}  x}}    => 3
  (test-equal? "app-5"
               (type-check `{{lam {x : Num} 
                       {+ {{lam {x : Num} x} 2} x}} 
                       1}) 
               (t-num))
  
  (test-equal? "app-6"
               (type-check `{{lam {x : Num} {+ x x}} 1})
               (t-num))
  
  (test-equal? "app-7"
               (type-check `{{{lam {x : Num} 
                        {lam {y : Num}
                        {+ x y}}} 3} 4}) 
               (t-num))

  ;; `{{lam f {f 3}} {lambda x {+ x x}}}  => 6 
  (test-equal? "app-8"
               (type-check `{{lam {f : {Num -> Num}} {f 3}} 
                       {lam {x : Num} {+ x x}}}) 
    (t-num))

  ;; `{let1 {x 1}
  ;;        {let1 {f {lambda y x}}
  ;;              {let1 {x 2}
  ;;                    {f 10}}}}
  ;; `{{\x -> {{\f -> {{\x -> {f 10}} 2}}{lam y x}}}1}
  (test-equal? "app-9"
    (type-check `{{lam {x : Num}  {{lam {f : {Num -> Num}} 
           {{lam {x : Num}  {f 10}} 2}} {lam {y : Num} x}}} 1}) 
    (t-num))

  ;; `{{let1 {x 3}
  ;;         {lambda y {+ x y}}}
  ;;   4}
  ;; `{{{\x -> {\y -> {+ x y}}}3}4}
  (test-equal? "app-10"
    (type-check `{{{lam {x : Num} {lam {y : Num} {+ x y}}}3}4}) 
           (t-num))

  ;; consider this SMoL program:
  ;; ((let ([y 3])
  ;;    (lambda (y) (+ y 1)))
  ;;  5)
  (test-equal? "app-11"
    (type-check `{{{lam {y : Num} {lam {y : Num} {+ y 1}}} 3} 5}) 
           (t-num))

  
  ;; (deffun (f x)
  ;;    (lambda (y) (+ x y)))
  ;; (defvar x 0)
  ;; ((f 2) 1)
  (test-equal? "app-12"
    (type-check `{{{{ lam {x : Num} 
          {lam {x : Num} 
          {lam {y : Num} 
          {+ x y}}}} 0} 2} 1}) (t-num))

  ;; INFO:
  ;; AND STATEMENT 

  ;; (test-raises-error? "and-01" (type-check `{and 5                  true}))
  ;; (test-raises-error? "and-02" (type-check `{and "str"              true}))
  ;; (test-raises-error? "and-03" (type-check `{and {lam {a : Num} a}  true}))
  ;; (test-raises-error? "and-04" (type-check `{and {empty : Num}      true}))
  ;;
  ;; (test-raises-error? "and-05" (type-check `{and true 5                }))
  ;; (test-raises-error? "and-06" (type-check `{and true "str"            }))
  ;; (test-raises-error? "and-07" (type-check `{and true {lam {a : Num} a}}))
  ;; (test-raises-error? "and-08" (type-check `{and true {empty : Num}    }))
  ;;
  ;; (test-equal? "and-1"
  ;;              (type-check `{and true true}) (t-bool))
  ;;
  ;; (test-equal? "and-2"
  ;;              (type-check `{and true false}) (t-bool))
  ;;
  ;; (test-equal? "and-3"
  ;;              (type-check `{and false true}) (t-bool))
  ;;
  ;; (test-equal? "and-4"
  ;;              (type-check `{and false false}) (t-bool))
  ;;
  ;; (test-equal? "and-5"
  ;;              (type-check `{and {and true true} true}) (t-bool))
  ;;
  ;; ;; short-circuit
  ;; ;; NOTE: not possible when we have type-checker
  ;; (test-raises-error? "and-06" (type-check `{and false 5                }))
  ;; (test-raises-error? "and-07" (type-check `{and false "str"            }))
  ;; (test-raises-error? "and-08" (type-check `{and false {lam a a}        }))
  ;; (test-raises-error? "and-08" (type-check `{and false {empty : Num}    }))
  ;;
  ;; ;; INFO:
  ;; ;; OR STATEMENT 
  ;;
  ;; (test-raises-error? "or-01" (type-check `{or 5                 false}))
  ;; (test-raises-error? "or-02" (type-check `{or "str"             false}))
  ;; (test-raises-error? "or-03" (type-check `{or {lam {a : Num} a} false}))
  ;; (test-raises-error? "or-04" (type-check `{or {empty : Num}     false}))
  ;;
  ;; (test-raises-error? "or-05" (type-check `{or false 5                }))
  ;; (test-raises-error? "or-06" (type-check `{or false "str"            }))
  ;; (test-raises-error? "or-07" (type-check `{or false {lam {a : Num} a}}))
  ;; (test-raises-error? "or-08" (type-check `{or false {empty : Num}    }))
  ;;
  ;; (test-equal? "or-1"
  ;;              (type-check `{or true true}) (t-bool))
  ;;
  ;; (test-equal? "or-2"
  ;;              (type-check `{or true false}) (t-bool))
  ;;
  ;; (test-equal? "or-3"
  ;;              (type-check `{or false true}) (t-bool))
  ;;
  ;; (test-equal? "or-4"
  ;;              (type-check `{or false false}) (t-bool))
  ;;
  ;; (test-equal? "or-5"
  ;;              (type-check `{or {or false true} false}) (t-bool))
  ;;
  ;; ;; short-circuit
  ;; ;; NOTE: not possible when we have type-checker
  ;; (test-raises-error? "or-06" (type-check `{or true 5                }))
  ;; (test-raises-error? "or-07" (type-check `{or true "str"            }))
  ;; (test-raises-error? "or-08" (type-check `{or true {lam a a}        }))
  ;; (test-raises-error? "or-08" (type-check `{or true {empty : Num}    }))

  ;; INFO:
  ;; LET STATEMENT 

  (test-raises-error? "let-0"
               (type-check `{let {x "foo"} {+ x 1}}))

  (test-raises-error? "let-1"
               (type-check `{let {x "foo"} {+ x 1}}))

  (test-equal? "let-2"
               (type-check `{let {x 5} x}) 
               (t-num))

  (test-equal? "let-3"
               (type-check `{let {x 5} 
                      {let {y {+ x 2}} 
                      {+ x y}}}) 
               (t-num))

  ;; shadowing
  (test-equal? "let-4"
               (type-check `{let {x 5} 
                      {let {x 3} x}}) 
               (t-num))

  ;; recursive definition
  ;; let x = \y -> x y
  (test-raises-error? "let-5"
               (type-check `{let {x {lam {y : Num} {x y}}}
                            {x 5}}))

)
;; DO NOT EDIT BELOW THIS LINE =================================================

(module+ main (run-tests student-tests))
