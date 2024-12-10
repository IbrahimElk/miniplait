#lang racket

;; =============================================================================
;; Lazy Typed Interpreter: lazyinterp-tests.rkt
;; =============================================================================

(require  "latyterp.rkt"
         "support.rkt"
         "test-support.rkt")

;; DO NOT EDIT ABOVE THIS LINE =================================================

(define/provide-test-suite student-tests ;; DO NOT EDIT THIS LINE ==========

  ;; INFO:
  ;; LAZY

  (test-raises-type-error? "lazy-1"
               (eval `{rec {x "foo" : Num} {+ x 1}}))

  (test-equal? "lazy-2"
               (eval `{rec {x 5 : Num} x}) 
               (v-num 5))

  (test-equal? "lazy-3"
               (eval `{rec {x 5 : Num} 
                      {rec {y {+ x 2} : Num} 
                      {+ x y}}}) 
               (v-num 12))

  ;; shadowing
  (test-equal? "lazy-4"
               (eval `{rec {x 5 : Num} 
                      {rec {x 3 : Num} x}}) 
               (v-num 3))

  ;; recursive definition
  ;; let x = \y -> x y
  ;; INFINITE LOOP IS POSSIBLE YAY! TUROING COMPLEZFEZENF MACHINEJZNEFZ
  ;; (test-equal? "lazy-5"
  ;;              (eval `{rec {x {lam {y : Num} {x y}} : {Num -> Num}}
  ;;                           {x 1}})
  ;;              (v-num 3))

  ;; actual and formal argument type need to correspond.
  (test-raises-type-error? "lazy-06.1"
               (eval `{rec {a "5" : Num} a}))

  ;; actual and formal argument type need to correspond.
  (test-raises-type-error? "lazy-06.2"
               (eval `{rec {a "5" : Bool} a}))

  ;; actual and formal argument type need to correspond.
  (test-raises-type-error? "lazy-06.3"
               (eval `{rec {a 5 : Str} a}))

  ;; actual and formal argument type need to correspond.
  (test-raises-type-error? "lazy-06.4"
               (eval `{rec {a "5" : {List Num}} a}))

  ;; actual and formal argument type need to correspond.
  (test-raises-type-error? "lazy-06.5"
               (eval `{rec {a "5" : {Num -> Num}} a}))

  (test-equal? "lazy-10"
    (eval `{rec {sum {lam {n : Num}
                          {if {num= n 0}
                              0
                              {+ n {sum {+ n -1}}}}} : {Num -> Num}}
      {sum 5}})
      (v-num 15))
    ;; 5 * 6 / 2 = 15 


  (test-equal? "lazy-11"
    (eval `{rec {list-gen {lam {n : Num}
                               {if {num= n 0}
                                   {empty : Num}
                                   {link n {list-gen {+ n -1}}}}} 
                                   : {Num -> {List Num}}}
      {first {list-gen 5}}})
    (v-num 5))

  (test-equal? "lazy-12"
  (eval `{rec {list-gen {lam {n : Num}
                             {if {num= n 0}
                                 {empty : Num}
                                 {link n {list-gen {+ n -1}}}}} 
                                 : {Num -> {List Num}}}
    {first {rest {list-gen 5}}}})
  (v-num 4))

  (test-equal? "lazy-13"
  (eval `{rec {list-gen {lam {n : Num}
                             {if {num= n 0}
                                 {empty : Num}
                                 {link n {list-gen {+ n -1}}}}}
                                 : {Num -> {List Num}}}
    {first {rest {rest {list-gen 5}}}}})
  (v-num 3))

  (test-equal? "lazy-14"
  (eval `{rec {list-gen {lam {n : Num}
                             {if {num= n 0}
                                 {empty : Num}
                                 {link n {list-gen {+ n -1}}}}}
                                 : {Num -> {List Num}}}
    {first {rest {rest {rest {list-gen 5}}}}}})
  (v-num 2))

  (test-equal? "lazy-15"
  (eval `{rec {list-gen {lam {n : Num}
                             {if {num= n 0}
                                 {empty : Num}
                                 {link n {list-gen {+ n -1}}}}}
                                 : {Num -> {List Num}}}
    {first {rest {rest {rest {rest {list-gen 5}}}}}}})
  (v-num 1))

  (test-equal? "lazy-16"
  (eval `{rec {list-gen {lam {n : Num}
                             {if {num= n 0}
                                 {empty : Num}
                                 {link n {list-gen {+ n -1}}}}}
                                 : {Num -> {List Num}}}
    {rest {rest {rest {rest {rest {list-gen 5}}}}}}})
  (v-empty))

  ;; NOTE: should raise error
  (test-raises-interp-error? "lazy-17"
  (eval `{rec {list-gen {lam {n : Num}
                             {if {num= n 0}
                                 {empty : Num}
                                 {link n {list-gen {+ n -1}}}}}
                                 : {Num -> {List Num}}}
    {first {rest {rest {rest {rest {rest {list-gen 5}}}}}}}}))

  (test-equal? "lazy-18"
  (eval
    `{rec {list-gen {lam {n : Num}
      {if {num= n 0}
        {empty : Num}
        {link n {list-gen {+ n -1}}}}} : {Num -> {List Num}}}
      {rec {take 
        {lam {n : Num}
          {lam {s : (List Num)}
            {if {num= n 0}
              {empty : Num}
              {link {first s} {{take {+ n -1}}{rest s}}}}}} 
              : (Num -> ((List Num) -> (List Num)))}

        {{take 0} {list-gen 5}}}})
  (v-empty))

  (test-equal? "lazy-19"
  (eval 
    `{rec {list-gen {lam {n : Num}
      {if {num= n 0}
        {empty : Num}
        {link n {list-gen {+ n -1}}}}} : {Num -> {List Num}}}
      {rec {take 
        {lam {n : Num}
          {lam {s : (List Num)}
            {if {num= n 0}
              {empty : Num}
              {link {first s} {{take {+ n -1}}{rest s}}}}}} 
              : (Num -> ((List Num) -> (List Num)))}
        {first {{take 2} {list-gen 5}}} }})
  (v-num 5))

  (test-equal? "lazy-20"
  (eval 
    `{rec {list-gen {lam {n : Num}
      {if {num= n 0}
        {empty : Num}
        {link n {list-gen {+ n -1}}}}} : {Num -> {List Num}}}
      {rec {take 
        {lam {n : Num}
          {lam {s : (List Num)}
            {if {num= n 0}
              {empty : Num}
              {link {first s} {{take {+ n -1}}{rest s}}}}}}
              : (Num -> ((List Num) -> (List Num)))}
        {first {{take 2} {list-gen 5}}} }})
  (v-num 5))

  (test-equal? "lazy-21"
    (eval 
      `{rec {nats-from
             {lam {n : Num}
               {link n {nats-from {+ 1 n}}}} : (Num -> (List Num))}
        {rec {take 
             {lam {n : Num}
               {lam {s : (List Num)}
                 {if {num= n 0}
                   {empty : Num}
                   {link {first s}
                   {{take {+ n -1}} {rest s}}}}}}
                   : (Num -> ((List Num) -> (List Num)))}
          {first {{take 3} {nats-from 0}}}}})
    (v-num 0))

  (test-equal? "lazy-22"
    (eval 
      `{rec {nats-from
             {lam {n : Num}
               {link n {nats-from {+ 1 n}}}} : (Num -> (List Num))}
        {rec {take 
             {lam {n : Num}
               {lam {s : (List Num)}
                 {if {num= n 0}
                   {empty : Num}
                   {link {first s}
                   {{take {+ n -1}} {rest s}}}}}}
                   : (Num -> ((List Num) -> (List Num)))}
          {{take 3} {nats-from 0}}}})
    (eval `{link 0 {link 1 {link 2 {empty : Num}}}}))


  ;; INFO:
  ;; BASIC

  (test-equal? "num-1"
               (eval `2) (v-num 2))
  
  (test-equal? "str-2"
               (eval `"hello") (v-str "hello"))

  (test-equal? "bool-3"
               (eval `true) (v-bool #t))

  (test-equal? "bool-4"
               (eval `false) (v-bool #f))

  (test-true   "lam-5"
               (v-fun? (eval `{lam {x : Num} 5})))

  (test-equal? "list-6"
               (eval `{empty : Str})
               (v-empty))

  ;; INFO:
  ;; BINARY OPERATIONS
  ;; ADDITION

  (test-raises-type-error? "op-plus-0"
               (eval `{+ 3 "5"}))

  (test-raises-type-error? "op-plus-1"
               (eval `{+ 3 true}))

  (test-raises-type-error? "op-plus-2"
               (eval `{+ 3 {lam {x : Num} x}}))

  (test-raises-type-error? "op-plus-3"
               (eval `{+ 3 {empty : Num}}))

  (test-raises-type-error? "op-plus-4"
               (eval `{+ "5" 3 }))

  (test-raises-type-error? "op-plus-5"
               (eval `{+ true 3}))

  (test-raises-type-error? "op-plus-6"
               (eval `{+ {lam {x : Num} x} 3}))

  (test-raises-type-error? "op-plus-7"
               (eval `{+ {empty : Num} 3}))

  (test-raises-type-error? "op-plus-8"
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

  (test-raises-type-error? "op-append-0"
               (eval `{++ "3" 5}))

  (test-raises-type-error? "op-append-1"
               (eval `{++ "3" true}))

  (test-raises-type-error? "op-append-2"
               (eval `{++ "3" {lam {x : Num} x}}))

  (test-raises-type-error? "op-append-3"
               (eval `{++ "3" {empty : Num}}))

  (test-raises-type-error? "op-append-4"
               (eval `{++ 5 "3" }))

  (test-raises-type-error? "op-append-5"
               (eval `{++ true "3"}))

  (test-raises-type-error? "op-append-6"
               (eval `{++ {lam {x : Num} x} "3"}))

  (test-raises-type-error? "op-append-7"
               (eval `{++ {empty : Num} "3"}))
  
  (test-equal? "op-append-8"
               (eval `{++ "3" "5"})
               (v-str "35"))

  (test-equal? "op-append-9"
               (eval `{++ "hello" {++ " " "world"}}) 
               (v-str "hello world"))
  
  ;; INFO:
  ;; STRING-EQUAL?

  (test-raises-type-error? "op-streq-0"
               (eval `{str= "3" 5}))

  (test-raises-type-error? "op-streq-1"
               (eval `{str= "3" true}))

  (test-raises-type-error? "op-streq-2"
               (eval `{str= "3" {lam {x : Num} x}}))

  (test-raises-type-error? "op-streq-3"
               (eval `{str= "3" {empty : Num}}))

  (test-raises-type-error? "op-streq-4"
               (eval `{str= 5 "3"}))

  (test-raises-type-error? "op-streq-5"
               (eval `{str= true "3"}))

  (test-raises-type-error? "op-streq-6"
               (eval `{str= {lam {x : Num} x} "3"}))

  (test-raises-type-error? "op-streq-7"
               (eval `{str= {empty : Num} "3"}))

  (test-equal? "op-streq-8"
               (eval `{str= "3" "5"})
               (v-bool #f))

  (test-equal? "op-streq-9"
               (eval `{str= "3" "3"})
               (v-bool #t))

  ;; INFO:
  ;; NUMBER-EQUAL? 

  (test-raises-type-error? "op-numeq-0"
               (eval `{num= 3 "5"}))

  (test-raises-type-error? "op-numeq-1"
               (eval `{num= 3 true}))

  (test-raises-type-error? "op-numeq-2"
               (eval `{num= 3 {lam {x : Num} x}}))

  (test-raises-type-error? "op-numeq-3"
               (eval `{num= 3 {empty : Num}}))

  (test-raises-type-error? "op-numeq-4"
               (eval `{num= "5" 3}))

  (test-raises-type-error? "op-numeq-5"
               (eval `{num= true 3}))

  (test-raises-type-error? "op-numeq-6"
               (eval `{num= {lam {x : Num} x} 3}))

  (test-raises-type-error? "op-numeq-7"
               (eval `{num= {empty : Num} 3}))

  (test-equal? "op-numeq-8"
               (eval `{num= 3 5})
               (v-bool #f))
  
  (test-equal? "op-numeq-9"
               (eval `{num= 3 3})
               (v-bool #t))

  ;; INFO:
  ;; LINK 

  ;; element to be added must have same type as list
  (test-raises-type-error? "op-link-0"
               (eval `{link 3 {empty : Bool}}))

  (test-raises-type-error? "op-link-1"
               (eval `{link "3" {empty : Bool}}))

  (test-raises-type-error? "op-link-2"
               (eval `{link true {empty : Num}}))

  (test-raises-type-error? "op-link-3"
               (eval `{link {lam {x : Num} x} {empty : Bool}}))

  (test-raises-type-error? "op-link-4"
               (eval `{link {empty : Num} {empty : Bool}}))

  (test-raises-type-error? "op-link-4.1"
               (eval `{link 3
                        {link "3"
                          {link false
                            {link {empty : Str}
                              {empty : Bool}}}}}))

  ;; expected a list for the second argument
  (test-raises-type-error? "op-link-5"
               (eval `{link "3" 5}))

  (test-raises-type-error? "op-link-6"
               (eval `{link "3" "5"}))

  (test-raises-type-error? "op-link-7"
               (eval `{link "3" true}))

  (test-raises-type-error? "op-link-8"
               (eval `{link "3" {lam {x : Num} x}}))

  ;; add element to list correctly
  (test-equal? "op-link-9"
               (eval `{link  3 {empty : Num}})
               (v-list (v-num 3) (v-empty)))

  (test-equal? "op-link-10"
               (eval `{link  "3" {empty : Str}})
               (v-list (v-str "3") (v-empty)))

  (test-equal? "op-link-11"
               (eval `{link  true {empty : Bool}})
               (v-list (v-bool true) (v-empty)))

  (test-equal? "op-link-12"
               (eval `{link  {empty : Bool} {empty : {List Bool}}})
               (v-list (v-empty) (v-empty)))

  (test-equal? "op-link-13"
               (eval `{link  3 {link  3 {empty : Num}}})
               (v-list (v-num 3) (v-list (v-num 3) (v-empty))))

  ;; INFO:
  ;; UNARY OPERATIONS
  ;; FIRST

  ;; first can only applied to lists
  (test-raises-type-error? "uop-first-O"
               (eval `{first 5}))

  ;; first can only applied to non empty lists
  (test-raises-interp-error? "uop-first-1"
               (eval `{first {empty : Num}}))

  ;; the type of the first element of an empty list is the type
  ;; of the list element
  (test-equal? "uop-first-2"
               (eval `{first {link 1 {empty : Num}}})
               (v-num 1))

  (test-equal? "uop-first-3"
               (eval `{first {link false {empty : Bool}}})
               (v-bool #f))

  (test-equal? "uop-first-4"
               (eval `{first {link "f" {empty : Str}}})
               (v-str "f"))

  (test-true  "uop-first-5"
               (v-fun? (eval `{first {link {lam {x : Num} 5} 
                                     {empty : {Num -> Num}}}})))

  (test-equal? "uop-first-6"
               (eval `{first {link {empty : Bool} {empty : {List Bool}}}})
               (v-empty))

  ;; INFO:
  ;; REST 

  ;; rest can only be applied to lists
  (test-raises-type-error? "uop-rest-O"
               (eval `{rest 5}))

  ;; rest can only be applied to non empty lists
  (test-raises-interp-error? "uop-rest-1"
               (eval `{rest {empty : Num}}))

  ;; the type of the rest of the list of an empty list is the type
  ;; of the list itself
  (test-equal? "uop-rest-2"
               (eval `{rest {link 1 {empty : Num}}})
               (v-empty))

  (test-equal? "uop-rest-3"
               (eval `{rest {link false {empty : Bool}}})
               (v-empty))

  (test-equal? "uop-rest-4"
               (eval `{rest {link "f" {empty : Str}}})
               (v-empty))

  (test-equal? "uop-rest-5"
               (eval `{rest {link {lam {x : Num} 5} 
                                  {empty : {Num -> Num}}}})
               (v-empty))

  ;; FIXME:
  (test-equal? "uop-rest-6"
               (eval `{rest {link {empty : Bool} 
                                  {empty : {List Bool}}}})
               (v-empty))

  ;; INFO:
  ;; IS-EMPTY?

  (test-raises-type-error? "isempty-0"
               (eval `{is-empty 5}))

  (test-equal? "uop-isempty-1"
               (eval `{is-empty {empty : Num}})
               (v-bool #t))

  (test-equal? "uop-isempty-2"
               (eval `{is-empty {empty : Bool}})
               (v-bool #t))

  (test-equal? "uop-isempty-3"
               (eval `{is-empty {empty : Str}})
               (v-bool #t))

  (test-equal? "uop-isempty-4"
               (eval `{is-empty {empty : {Num -> Num}}})
               (v-bool #t))

  (test-equal? "uop-isempty-5"
               (eval `{is-empty {empty : {List Num}}})
               (v-bool #t))

  (test-equal? "uop-isempty-6"
               (eval `{is-empty {empty : {List Num}}})
               (v-bool #t))

  (test-equal? "uop-isempty-7"
               (eval `{is-empty {link 1 {empty : Num}}})
               (v-bool #f))

  (test-equal? "uop-isempty-8"
               (eval `{is-empty {link false {empty : Bool}}})
               (v-bool #f))

  (test-equal? "uop-isempty-9"
               (eval `{is-empty {link "f" {empty : Str}}})
               (v-bool #f))

  (test-equal? "uop-isempty-10"
               (eval `{is-empty {link {lam {x : Num} 5} 
                                {empty : {Num -> Num}}}})
               (v-bool #f))

  ;; FIXME: fix dit ook
  ;; (test-equal? "uop-isempty-11"
  ;;              (eval `{is-empty {link {empty : Bool} 
  ;;                               {empty : {List Bool}}}})
  ;;              (v-bool #f))

  ;; INFO:
  ;; IF STATEMENT 

  ;; condition needs to be boolean
  (test-raises-type-error? "if-0"
               (eval `{if 5 5 5}))

  ;; branches of if need to be of same type
  (test-raises-type-error? "if-1"
               (eval `{if false 5 false}))

  ;; branches of if need to be of same type
  (test-raises-type-error? "if-2"
               (eval `{if false 
                        {lam {a : Num} 5 }
                        {lam {y : Num} "5"}}))

  ;; branches of if need to be of same type
  (test-raises-type-error? "if-3"
               (eval `{if false
                   {empty : Num} 
                   {empty : Str}}))

  ;; branches of if need to be of same type
  (test-raises-type-error? "if-4"
               (eval `{if true false "5"}))

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
                        {lam {a : Num} 5} 
                        {lam {y : Num} 1}})))

  (test-equal? "if-10"
               (eval `{if true 
                   {empty : Num} 
                   {link 1 {empty : Num}}})
               (v-empty))

  ;; short-circuit  
  ;; NOTE: not possible when we have type-checker
  (test-raises-type-error? "and-11"
               (eval `{if true "short" {+ 5 "error skibidi"}}))

  ;; short-circuit
  ;; NOTE: not possible when we have type-checker
  (test-raises-type-error? "and-12"
               (eval `{if false {+ 5 "error skibidi"} "short"}))


  ;; INFO:
  ;; LAM STATEMENT 

  (test-equal? "lam-0" (eval `{lam {a : Num} a})
               (v-fun 'a (e-var 'a) '#hash()))

  ;; INFO:
  ;; APP STATEMENT 
  ;;
  (test-raises-type-error? "app-01"
               (eval `{5 5}))

  (test-raises-type-error? "app-02"
               (eval `{"5" 5}))

  (test-raises-type-error? "app-03"
               (eval `{false 5}))

  (test-raises-type-error? "app-04"
               (eval `{{empty : Num} 5}))

  (test-raises-type-error? "app-05"
               (eval `{f 5}))

  ;; actual and formal argument type need to correspond. 
  (test-raises-type-error? "app-06"
               (eval `{{lam {a : Num} a} "5"}))

  ;; actual and formal argument type need to correspond. 
  (test-raises-type-error? "app-06.1"
               (eval `{{lam {a : Num} a} "5"}))

  ;; actual and formal argument type need to correspond. 
  (test-raises-type-error? "app-06.2"
               (eval `{{lam {a : Bool} a} "5"}))

  ;; actual and formal argument type need to correspond. 
  (test-raises-type-error? "app-06.3"
               (eval `{{lam {a : Str} a} 5}))

  ;; actual and formal argument type need to correspond. 
  (test-raises-type-error? "app-06.4"
               (eval `{{lam {a : {List Num}} a} "5"}))

  ;; actual and formal argument type need to correspond. 
  (test-raises-type-error? "app-06.5"
               (eval `{{lam {a : {Num -> Num}} a} "5"}))

  (test-raises-type-error? "app-07"
               (eval `{{lam {x : Num} y} 1}))

  ;; scoping 
  (test-raises-type-error? "app-08"
               (eval `{+ {{lam {x : Num} x} 1}  x}))

  ;; shadowing
  (test-equal? "app-1"
               (eval `{{lam {x : Num}
                        {{lam {x : Num}
                          x} 3}} 5})
               (v-num 3))

  (test-equal? "app-4"
               (eval `{{lam {a : Num} a} 5})
               (v-num 5))

  ;; `{let {x 1} {+ {let {x 2}   x}  x}}    => 3
  (test-equal? "app-5"
               (eval `{{lam {x : Num} 
                       {+ {{lam {x : Num} x} 2} x}} 
                       1}) 
               (v-num 3))

  (test-equal? "app-6"
               (eval `{{lam {x : Num} {+ x x}} 1})
               (v-num 2))

  (test-equal? "app-7"
               (eval `{{{lam {x : Num} 
                        {lam {y : Num}
                        {+ x y}}} 3} 4}) 
               (v-num 7))

  ;; `{{lam f {f 3}} {lambda x {+ x x}}}  => 6 
  (test-equal? "app-8"
               (eval `{{lam {f : {Num -> Num}} {f 3}} 
                       {lam {x : Num} {+ x x}}}) 
    (v-num 6))

  ;; `{let1 {x 1}
  ;;        {let1 {f {lambda y x}}
  ;;              {let1 {x 2}
  ;;                    {f 10}}}}
  ;; `{{\x -> {{\f -> {{\x -> {f 10}} 2}}{lam y x}}}1}
  (test-equal? "app-9"
    (eval `{{lam {x : Num}  {{lam {f : {Num -> Num}} 
           {{lam {x : Num}  {f 10}} 2}} {lam {y : Num} x}}} 1}) 
    (v-num 1))

  ;; `{{let1 {x 3}
  ;;         {lambda y {+ x y}}}
  ;;   4}
  ;; `{{{\x -> {\y -> {+ x y}}}3}4}
  (test-equal? "app-10"
    (eval `{{{lam {x : Num} {lam {y : Num} {+ x y}}}3}4}) 
           (v-num 7))

  ;; consider this SMoL program:
  ;; ((let ([y 3])
  ;;    (lambda (y) (+ y 1)))
  ;;  5)
  (test-equal? "app-11"
    (eval `{{{lam {y : Num} {lam {y : Num} {+ y 1}}} 3} 5}) 
           (v-num 6))


  ;; (deffun (f x)
  ;;    (lambda (y) (+ x y)))
  ;; (defvar x 0)
  ;; ((f 2) 1)
  (test-equal? "app-12"
    (eval `{{{{ lam {x : Num} 
          {lam {x : Num} 
          {lam {y : Num} 
          {+ x y}}}} 0} 2} 1}) (v-num 3))

  ;; INFO:
  ;; AND STATEMENT 

  (test-raises-type-error? "and-01" (eval `{and 5                  true}))
  (test-raises-type-error? "and-02" (eval `{and "str"              true}))
  (test-raises-type-error? "and-03" (eval `{and {lam {a : Num} a}  true}))
  (test-raises-type-error? "and-04" (eval `{and {empty : Num}      true}))

  (test-raises-type-error? "and-05" (eval `{and true 5                }))
  (test-raises-type-error? "and-06" (eval `{and true "str"            }))
  (test-raises-type-error? "and-07" (eval `{and true {lam {a : Num} a}}))
  (test-raises-type-error? "and-08" (eval `{and true {empty : Num}    }))

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
  ;; NOTE: not the case when we have the type-checker 
  (test-raises-type-error? "and-09" (eval `{and false 5                 }))
  (test-raises-type-error? "and-10" (eval `{and false "str"             }))
  (test-raises-type-error? "and-11" (eval `{and false {lam {a : Num} a} }))
  (test-raises-type-error? "and-12" (eval `{and false {empty : Num}     }))

  ;; INFO:
  ;; OR STATEMENT 

  (test-raises-type-error? "or-01" (eval `{or 5                 false}))
  (test-raises-type-error? "or-02" (eval `{or "str"             false}))
  (test-raises-type-error? "or-03" (eval `{or {lam {a : Num} a} false}))
  (test-raises-type-error? "or-04" (eval `{or {empty : Num}     false}))

  (test-raises-type-error? "or-05" (eval `{or false 5                }))
  (test-raises-type-error? "or-06" (eval `{or false "str"            }))
  (test-raises-type-error? "or-07" (eval `{or false {lam {a : Num} a}}))
  (test-raises-type-error? "or-08" (eval `{or false {empty : Num}    }))

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
  ;; NOTE: not the case when we have the type-checker 
  (test-raises-type-error? "or-09" (eval `{or true 5                 }))
  (test-raises-type-error? "or-10" (eval `{or true "str"             }))
  (test-raises-type-error? "or-11" (eval `{or true {lam {a : Num}  a}}))
  (test-raises-type-error? "or-12" (eval `{or true {empty : Num}     }))

  ;; INFO:
  ;; LET STATEMENT 

  (test-raises-type-error? "let-1"
               (eval `{let {x "foo" : Num} {+ x 1}}))

  (test-equal? "let-2"
               (eval `{let {x 5 : Num} x}) 
               (v-num 5))

  (test-equal? "let-3"
               (eval `{let {x 5 : Num} 
                      {let {y {+ x 2} : Num} 
                      {+ x y}}}) 
               (v-num 12))

  ;; shadowing
  (test-equal? "let-4"
               (eval `{let {x 5 : Num} 
                      {let {x 3 : Num} x}}) 
               (v-num 3))

  ;; recursive definition
  ;; let x = \y -> x y
  (test-raises-type-error? "let-5"
                (eval `{let {x {lam {y : Num} {x y}} : {Num -> Num}}
                             {x 5}}))

  ;; actual and formal argument type need to correspond. 
  (test-raises-type-error? "let-06.1"
               (eval `{let {a "5" : Num} a}))

  ;; actual and formal argument type need to correspond. 
  (test-raises-type-error? "let-06.2"
               (eval `{let {a "5" : Bool} a}))

  ;; actual and formal argument type need to correspond. 
  (test-raises-type-error? "let-06.3"
               (eval `{let {a 5 : Str} a}))

  ;; actual and formal argument type need to correspond. 
  (test-raises-type-error? "let-06.4"
               (eval `{let {a "5" : {List Num}} a}))

  ;; actual and formal argument type need to correspond. 
  (test-raises-type-error? "let-06.5"
               (eval `{let {a "5" : {Num -> Num}} a}))

)

;; DO NOT EDIT BELOW THIS LINE =================================================

(module+ main (run-tests student-tests))
