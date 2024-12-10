#lang plait

;; ➜  4-tynterp (main) racket temp.rkt                                              ✭ ✱
;; first: contract violation
;;   expected: (and/c list? (not/c empty?))
;;   given: '()
;;   context...:
;;    /home/ibrahim/.local/share/racket/8.14/pkgs/plait/main.rkt:3581:20
;;    body of "/home/ibrahim/Documents/KuLeuven/Engineering/Master/2e_fase/1e_semester/comparative_programming_languages/miniplait-r0855183/code/4-tynterp/temp.rkt"
;; (first empty)
;; (rest empty)


;; plait has the condition
;; that the branches should 
;; have the same type.

;; > (if True "e" "f")
;; . True: free variable while typechecking in: True
;; > (if #t "e" "f")
;; - String
;; "e"
;; > (if #t "e" 0)
;; . typecheck failed: String vs. Number in:
;;   "e"
;;   0
;;
;; REMOVED UNBOUND ERROR BIJ INTERPRETER.
;; (type-case (Optionof Value) (hash-ref env s)
;;   [(none) (raise-interp-error 
;;             (string-append (symbol->string s) " not bound"))]
;;   [(some value) value]))
;;





;; INFO: making env a mutable env, resulted in errors!
;;
;; (define empty-env (make-hash empty))
;;
;; (lookup : (Env Symbol -> Value))
;; (define (lookup env s)
;;   (let ([x (hash-ref env s)])
;;     (some-v x))
;; )
;;
;; (extend : (Env Symbol Value -> Env))
;; (define (extend old-env new-name value)
;;   (let ([_ (hash-set! old-env new-name value)])
;;     old-env)
;; )
;;
;; (define empty-envt (make-hash empty))
;;
;; (lookupt : (TEnv Symbol -> Type))
;; (define (lookupt env s)
;;   (type-case (Optionof Type) (hash-ref env s)
;;     [(none) (raise-type-error
;;               (string-append (symbol->string s) " not bound"))]
;;     [(some type) type]))
;;
;; (extendt : (TEnv Symbol Type -> TEnv))
;; (define (extendt old-env new-name type)
;;   (let ([_ (hash-set! old-env new-name type)])
;;     old-env)
;; )
;; ➜  4-tynterp (main) racket tynterp-tests.rkt                              ✭ ✱
;; --------------------
;; student-tests > app-3
;; FAILURE
;; name:       check-with-timeout-exn
;; location:   test-support.rkt:172:18
;; params:
;;   '(#<procedure:...rp/test-support.rkt:178:13>
;;   #<procedure:...rp/test-support.rkt:179:13>)
;; message:    "No exception raised"
;; --------------------
;; --------------------
;; student-tests > app-5
;; FAILURE
;; name:       check-with-timeout-equal?
;; location:   test-support.rkt:143:18
;; actual:     (v-num 4)
;; expected:   (v-num 3)
;; --------------------
;; --------------------
;; student-tests > app-9
;; FAILURE
;; name:       check-with-timeout-equal?
;; location:   test-support.rkt:143:18
;; actual:     (v-num 2)
;; expected:   (v-num 1)
;; --------------------
;; --------------------
;; student-tests > let-2
;; FAILURE
;; name:       check-with-timeout-exn
;; location:   test-support.rkt:172:18
;; params:
;;   '(#<procedure:...rp/test-support.rkt:178:13>
;;   #<procedure:...rp/test-support.rkt:179:13>)
;; message:    "No exception raised"
;; --------------------
;; 123 success(es) 4 failure(s) 0 error(s) 127 test(s) run
;; 4




















































;;
;;
;;
;; (define/provide-test-suite student-tests ;; DO NOT EDIT THIS LINE ==========
;;
;;   ;; FIXME: transform everything here to 
;;   ;; `eval`. Don't change the type of error raised !!
;;   ;; if you can't get the error, remove it.
;;   ;; use an wrong-typed program to get the interp
;;   ;; error raised!
;;   ;;     `{lam {x : {List Num}} {first x}}
;;   ;;     `{lam {x : Num} {+ true x}}
;;   ;;     `{lam {x : Num} {is-empty x}}`
;;   ;;     `{lam {x : {List Num}} {link "oops" x}}`
;;   ;;     `{lam {x : Num} {x (x x)}}`
;;   ;;     `{lam {f : {Num -> Num}} {f "1"}}`
;;   ;;     `{lam {x : Str} {++ x 5}}`
;;   ;;     `{first {empty : {List Num}}}
;;   ;;
;;   ;;      check eens
;;   ;;     `{lam {x : Num} x}  -> unbound error van interpreter!!
;;   ;;    
;;
;;   ;; TODO:
;;   ;; HIERONDER VERAVANGEN MET type-of-with-env-var
;;   ;; en interp-with-env-var 
;;
;;   ;; VALUE->STRING
;;   (test-equal? "value->string-0"
;;                (value->string (v-str "a")) 
;;                "string: \"a\"")
;;
;;   (test-equal? "value->string-1"
;;                (value->string (v-num 3)) 
;;                "number")
;;
;;   (test-equal? "value->string-2"
;;                (value->string (v-bool #t)) 
;;                "boolean: true")
;;
;;   (test-equal? "value->string-3"
;;                (value->string my-fun-test) 
;;                "function: parameter x")
;;
;;   (test-equal? "value->string-4"
;;                (value->string (v-list (list (v-num 3)))) 
;;                "list")
;;
;;   ;; TYPE->STRING
;;   (test-equal? "type->string-0"
;;                (type->string (t-str)) 
;;                "string") 
;;
;;   (test-equal? "type->string-1"
;;                (type->string (t-num)) 
;;                "number") 
;;
;;   (test-equal? "type->string-2"
;;                (type->string (t-bool)) 
;;                "boolean")
;;
;;   (test-equal? "type->string-3"
;;                (type->string (t-fun (t-num) (t-num)))
;;                "function: number -> number")
;;
;;   (test-equal? "type->string-4"
;;                (type->string (t-list (t-num))) 
;;                "list of number")
;;
;;
;;   ;; INFO:
;;   ;; TYPE-CHECKER
;;   ;; BINARY OPERATIONS
;;   ;; ADDITION
;;
;;   (test-raises-type-error? "type-of-with-env-op-plus-0"
;;                (type-of-with-env-op 
;;                  (op-plus) (e-num 3) (e-str "5") my-empty-env))
;;
;;   (test-raises-type-error? "type-of-with-env-op-plus-1"
;;                (type-of-with-env-op 
;;                  (op-plus) (e-str "3") (e-num 5) my-empty-env))
;;
;;   (test-equal? "type-of-with-env-op-plus-2"
;;                (type-of-with-env-op 
;;                  (op-plus) (e-num 3) (e-num 5) my-empty-env)
;;                (t-num))
;;
;;   ;; INFO:
;;   ;; TYPE-CHECKER
;;   ;; APPENDING
;;
;;   (test-raises-type-error? "type-of-with-env-op-append-0"
;;                (type-of-with-env-op 
;;                  (op-append) (e-num 3) (e-str "5") my-empty-env))
;;
;;   (test-raises-type-error? "type-of-with-env-op-append-1"
;;                (type-of-with-env-op 
;;                  (op-append) (e-str "3") (e-num 5) my-empty-env))
;;
;;   (test-equal? "type-of-with-env-op-append-2"
;;                (type-of-with-env-op 
;;                  (op-append) (e-str "3") (e-str "5") my-empty-env)
;;                (t-str))
;;
;;   ;; INFO:
;;   ;; TYPE-CHECKER
;;   ;; STRING-EQUAL?
;;
;;   (test-raises-type-error? "type-of-with-env-op-streq-0"
;;                (type-of-with-env-op 
;;                  (op-str-eq) (e-num 3) (e-str "5") my-empty-env))
;;
;;   (test-raises-type-error? "type-of-with-env-op-streq-1"
;;                (type-of-with-env-op 
;;                  (op-str-eq) (e-str "3") (e-num 5) my-empty-env))
;;
;;   (test-equal? "type-of-with-env-op-streq-2"
;;                (type-of-with-env-op 
;;                  (op-str-eq) (e-str "3") (e-str "5") my-empty-env)
;;                (t-bool))
;;
;;   ;; INFO:
;;   ;; TYPE-CHECKER
;;   ;; NUMBER-EQUAL? 
;;
;;   (test-raises-type-error? "type-of-with-env-op-numeq-0"
;;                (type-of-with-env-op 
;;                  (op-num-eq) (e-num 3) (e-str "5") my-empty-env))
;;
;;   (test-raises-type-error? "type-of-with-env-op-numeq-1"
;;                (type-of-with-env-op 
;;                  (op-num-eq) (e-str "3") (e-num 5) my-empty-env))
;;
;;   (test-equal? "type-of-with-env-op-numeq-2"
;;                (type-of-with-env-op 
;;                  (op-num-eq) (e-num 3) (e-num 5) my-empty-env)
;;                (t-bool))
;;
;;   ;; INFO:
;;   ;; TYPE-CHECKER
;;   ;; LINK 
;;
;;   ;; expected a list for the second argument
;;   (test-raises-type-error? "type-of-with-env-op-link-0"
;;                (type-of-with-env-op 
;;                  (op-link) (e-num 3) (e-empty (t-bool)) my-empty-env))
;;
;;   ;; element to be added must have same type as list
;;   (test-raises-type-error? "type-of-with-env-op-link-1"
;;                (type-of-with-env-op 
;;                  (op-link) (e-str "3") (e-num 5) my-empty-env))
;;
;;   (test-equal? "type-of-with-env-op-link-2"
;;                (type-of-with-env-op 
;;                  (op-link) (e-num 3) (e-empty (t-num)) my-empty-env)
;;                (t-list(t-num)))
;;
;;   (test-equal? "type-of-with-env-op-link-3"
;;                (type-of-with-env-op 
;;                  (op-link) (e-str "3") (e-empty (t-str)) my-empty-env)
;;                (t-list(t-str)))
;;
;;
;;   ;; INFO:
;;   ;; TYPE-CHECKER
;;   ;; UNARY OPERATIONS
;;   ;; FIRST
;;
;;   (test-raises-type-error? "type-of-with-env-uop-first-O"
;;                (type-of-with-env-uop 
;;                  (op-first) (e-num 5) my-empty-env))
;;
;;   ;; the type of the first element of an empty list is the type
;;   ;; of the list element
;;   (test-equal? "type-of-with-env-uop-first-1"
;;                (type-of-with-env-uop 
;;                  (op-first) (e-empty (t-num)) my-empty-env)
;;                (t-num))
;;
;;   (test-equal? "type-of-with-env-uop-first-2"
;;                (type-of-with-env-uop 
;;                  (op-first) (e-empty (t-bool)) my-empty-env)
;;                (t-bool))
;;
;;   (test-equal? "type-of-with-env-uop-first-3"
;;                (type-of-with-env-uop 
;;                  (op-first) (e-empty (t-str)) my-empty-env)
;;                (t-str))
;;
;;   (test-equal? "type-of-with-env-uop-first-4"
;;                (type-of-with-env-uop 
;;                  (op-first) 
;;                  (e-empty (t-fun (t-num) (t-num)))
;;                  my-empty-env)
;;                (t-fun (t-num) (t-num)))
;;
;;   (test-equal? "type-of-with-env-uop-first-5"
;;                (type-of-with-env-uop 
;;                  (op-first) 
;;                  (e-empty (t-list (t-bool)))
;;                  my-empty-env)
;;                (t-list (t-bool)))
;;
;;   ;; INFO:
;;   ;; TYPE-CHECKER
;;   ;; REST 
;;
;;   (test-raises-type-error? "type-of-with-env-uop-rest-O"
;;                (type-of-with-env-uop 
;;                  (op-rest) (e-num 5) my-empty-env))
;;
;;   ;; the type of the rest of the list of an empty list is the type
;;   ;; of the list itself
;;   (test-equal? "type-of-with-env-uop-rest-1"
;;                (type-of-with-env-uop 
;;                  (op-rest) (e-empty (t-num)) my-empty-env)
;;                (t-list (t-num)))
;;
;;   (test-equal? "type-of-with-env-uop-rest-2"
;;                (type-of-with-env-uop 
;;                  (op-rest) (e-empty (t-bool)) my-empty-env)
;;                (t-list (t-bool)))
;;
;;   (test-equal? "type-of-with-env-uop-rest-3"
;;                (type-of-with-env-uop 
;;                  (op-rest) (e-empty (t-str)) my-empty-env)
;;                (t-list (t-str)))
;;
;;   (test-equal? "type-of-with-env-uop-rest-4"
;;                (type-of-with-env-uop 
;;                  (op-rest) 
;;                  (e-empty (t-fun (t-num) (t-num)))
;;                  my-empty-env)
;;                (t-list (t-fun (t-num) (t-num))))
;;
;;   (test-equal? "type-of-with-env-uop-rest-5"
;;                (type-of-with-env-uop 
;;                  (op-rest) 
;;                  (e-empty (t-list (t-bool)))
;;                  my-empty-env)
;;                (t-list (t-list (t-bool))))
;;
;;   ;; INFO:
;;   ;; TYPE-CHECKER
;;   ;; IS-EMPTY?
;;
;;
;;   (test-raises-type-error? "type-of-with-env-uop-isempty-0"
;;                (type-of-with-env-uop 
;;                  (op-is-empty) (e-num 5) my-empty-env))
;;
;;   (test-equal? "type-of-with-env-uop-isempty-1"
;;                (type-of-with-env-uop 
;;                  (op-is-empty) (e-empty (t-num)) my-empty-env)
;;                (t-bool))
;;
;;   (test-equal? "type-of-with-env-uop-isempty-2"
;;                (type-of-with-env-uop 
;;                  (op-is-empty) (e-empty (t-bool)) my-empty-env)
;;                (t-bool))
;;
;;   (test-equal? "type-of-with-env-uop-isempty-3"
;;                (type-of-with-env-uop 
;;                  (op-is-empty) (e-empty (t-str)) my-empty-env)
;;                (t-bool))
;;
;;   (test-equal? "type-of-with-env-uop-isempty-4"
;;                (type-of-with-env-uop 
;;                  (op-is-empty) 
;;                  (e-empty (t-fun (t-num) (t-num)))
;;                  my-empty-env)
;;                (t-bool))
;;
;;   (test-equal? "type-of-with-env-uop-isempty-5"
;;                (type-of-with-env-uop 
;;                  (op-is-empty) 
;;                  (e-empty (t-list (t-bool)))
;;                  my-empty-env)
;;                (t-bool))
;;
;;   ;; INFO:
;;   ;; TYPE-CHECKER
;;   ;; IF STATEMENT 
;;
;;   (test-raises-type-error? "type-of-with-env-if-0"
;;                (type-of-with-env-if
;;                  (e-num 5) (e-num 5) (e-num 5) my-empty-env))
;;
;;   (test-raises-type-error? "type-of-with-env-if-1"
;;                (type-of-with-env-if
;;                  (e-bool #t) (e-num 5) (e-bool #f) my-empty-env))
;;
;;   (test-raises-type-error? "type-of-with-env-if-2"
;;                (type-of-with-env-if
;;                   (e-bool #f) 
;;                       (e-lam 'a (t-num) (e-num 5)) 
;;                       (e-lam 'y (t-num) (e-str "1"))
;;                       my-empty-env))
;;
;;   (test-raises-type-error? "type-of-with-env-if-3"
;;                (type-of-with-env-if
;;                  (e-bool #f) 
;;                    (e-empty (t-num)) 
;;                    (e-empty (t-str)) 
;;                    my-empty-env))
;;
;;   (test-raises-type-error? "type-of-with-env-if-4"
;;                (type-of-with-env-if
;;                  (e-bool #t) (e-bool #f) (e-str "5") my-empty-env))
;;
;;   (test-equal? "type-of-with-env-if-5"
;;                (type-of-with-env-if
;;                  (e-bool #t) (e-num 3) (e-num 5) my-empty-env)
;;                (t-num))
;;
;;   (test-equal? "type-of-with-env-if-6"
;;                (type-of-with-env-if
;;                  (e-bool #f) (e-str "3") (e-str "5") my-empty-env)
;;                (t-str))
;;
;;   (test-equal? "type-of-with-env-if-7"
;;                (type-of-with-env-if
;;                  (e-bool #f) (e-bool #f) (e-bool #t) my-empty-env)
;;                (t-bool))
;;
;;   (test-equal? "type-of-with-env-if-8"
;;                (type-of-with-env-if
;;                   (e-bool #f) 
;;                     (e-lam 'a (t-num) (e-num 5)) 
;;                     (e-lam 'y (t-num) (e-num 1))
;;                     my-empty-env)
;;                (t-fun (t-num) (t-num)))
;;
;;   (test-equal? "type-of-with-env-if-9"
;;                (type-of-with-env-if
;;                  (e-bool #f) 
;;                    (e-empty (t-num)) 
;;                    (e-empty (t-num)) 
;;                    my-empty-env)
;;                (t-list (t-num)))
;;
;;   ;; INFO:
;;   ;; TYPE-CHECKER
;;   ;; LAM STATEMENT 
;;
;;   (test-equal? "type-of-with-env-lam-0"
;;                (type-of-with-env-lam 'a (t-num) (e-var 'a) my-empty-env)
;;                (t-fun (t-num) (t-num)))
;;
;;   ;; INFO:
;;   ;; TYPE-CHECKER
;;   ;; APP STATEMENT 
;;
;;   (test-raises-type-error? "type-of-with-env-app-1"
;;                (type-of-with-env-app
;;                  (e-num 5) 
;;                  (e-num 5)
;;                  my-empty-env))
;;
;;   (test-raises-type-error? "type-of-with-env-app-2"
;;                (type-of-with-env-app
;;                  (e-lam 'a (t-num) (e-var 'a)) 
;;                  (e-str "5")
;;                  my-empty-env))
;;
;;   (test-equal? "type-of-with-env-app-3"
;;                (type-of-with-env-app 
;;                  (e-lam 'a (t-num) (e-var 'a))
;;                  (e-num 5) 
;;                  my-empty-env)
;;                (t-num))
;;
;;   ;; INFO:
;;   ;; INTERPRETER 
;;   ;; BINARY OPERATIONS
;;   ;; ADDITION 
;;
;;   (test-raises-interp-error? "interp-with-env-op-plus-0"
;;                (interp-with-env-op 
;;                  (op-plus) (e-num 3) (e-str "5") my-empty-env))
;;
;;   (test-raises-interp-error? "interp-with-env-op-plus-1"
;;                (interp-with-env-op 
;;                  (op-plus) (e-str "3") (e-num 5) my-empty-env))
;;
;;   (test-equal? "interp-with-env-op-plus-2"
;;                (interp-with-env-op 
;;                  (op-plus) (e-num 3) (e-num 5) my-empty-env)
;;                (v-num 8))
;;
;;   ;; INFO:
;;   ;; INTERPRETER 
;;   ;; APPENDING
;;
;;   (test-raises-interp-error? "interp-with-env-op-append-0"
;;                (interp-with-env-op 
;;                  (op-append) (e-num 3) (e-str "5") my-empty-env))
;;
;;   (test-raises-interp-error? "interp-with-env-append-1"
;;                (interp-with-env-op 
;;                  (op-append) (e-str "3") (e-num 5) my-empty-env))
;;
;;   (test-equal? "interp-with-env-append-2"
;;                (interp-with-env-op 
;;                  (op-append) (e-str "3") (e-str "5") my-empty-env)
;;                (v-str "35"))
;;
;;   ;; INFO:
;;   ;; INTERPRETER 
;;   ;; STRING-EQUAL?
;;
;;   (test-raises-interp-error? "interp-with-env-op-streq-0"
;;                (interp-with-env-op 
;;                  (op-str-eq) (e-num 3) (e-str "5") my-empty-env))
;;
;;   (test-raises-interp-error? "interp-with-env-op-streq-1"
;;                (interp-with-env-op 
;;                  (op-str-eq) (e-str "3") (e-num 5) my-empty-env))
;;
;;   (test-equal? "interp-with-env-op-streq-2"
;;                (interp-with-env-op 
;;                  (op-str-eq) (e-str "3") (e-str "5") my-empty-env)
;;                (v-bool #f))
;;
;;   ;; INFO:
;;   ;; INTERPRETER 
;;   ;; NUMBER-EQUAL? 
;;
;;   (test-raises-interp-error? "interp-with-env-op-numeq-0"
;;                (interp-with-env-op 
;;                  (op-num-eq) (e-num 3) (e-str "5") my-empty-env))
;;
;;   (test-raises-interp-error? "interp-with-env-op-numeq-1"
;;                (interp-with-env-op 
;;                  (op-num-eq) (e-str "3") (e-num 5) my-empty-env))
;;
;;   (test-equal? "interp-with-env-op-numeq-2"
;;                (interp-with-env-op 
;;                  (op-num-eq) (e-num 3) (e-num 5) my-empty-env)
;;                (v-bool #f))
;;
;;   ;; INFO:
;;   ;; INTERPRETER 
;;   ;; LINK 
;;
;;   ;; expected a list for the second argument
;;   (test-raises-interp-error? "interp-of-with-env-op-link-1"
;;                (interp-with-env-op 
;;                  (op-link) (e-str "3") (e-num 5) my-empty-env))
;;
;;   ;; element to be added must have same type as list
;;   ;; interp doesn't catch type errors!
;;   (test-equal? "interp-with-env-op-link-0"
;;                (interp-with-env-op 
;;                  (op-link) (e-num 3) 
;;                  (e-op (op-link) (e-num 3) (e-empty (t-bool)))
;;                  my-empty-env)
;;                (v-list (list (v-num 3) (v-num 3))))
;;
;;   (test-equal? "interp-of-with-env-op-link-2"
;;                (interp-with-env-op 
;;                  (op-link) (e-num 3) (e-empty (t-num)) my-empty-env)
;;                (v-list (list (v-num 3))))
;;
;;   (test-equal? "interp-of-with-env-op-link-3"
;;                (interp-with-env-op 
;;                  (op-link) (e-str "3") (e-empty (t-str)) my-empty-env)
;;                (v-list (list (v-str "3"))))
;;
;;
;;   ;; INFO:
;;   ;; INTERPRETER 
;;   ;; UNARY OPERATIONS
;;   ;; FIRST
;;
;;   (test-raises-interp-error? "interp-with-env-uop-first-O"
;;                (interp-with-env-uop 
;;                  (op-first) (e-num 5) my-empty-env))
;;
;;   (test-raises-interp-error? "interp-with-env-uop-first-1"
;;                (interp-with-env-uop 
;;                  (op-first) (e-empty (t-num)) my-empty-env))
;;
;;   (test-equal? "interp-with-env-uop-first-2"
;;                (interp-with-env-uop 
;;                  (op-first) 
;;                  (e-op (op-link) (e-num 3) (e-empty (t-bool)))
;;                  my-empty-env)
;;                (v-num 3))
;;
;;   (test-equal? "interp-with-env-uop-first-3"
;;                (interp-with-env-uop 
;;                  (op-first) 
;;                  (e-op (op-link) (e-str "3") (e-empty (t-bool)))
;;                  my-empty-env)
;;                (v-str "3"))
;;
;;   (test-equal? "interp-with-env-uop-first-4"
;;                (interp-with-env-uop 
;;                  (op-first) 
;;                  (e-op (op-link) 
;;                        (e-lam 'a (t-num) (e-num 5)) 
;;                        (e-empty (t-bool)))
;;                  my-empty-env)
;;                (v-fun 'a (e-num 5) my-empty-env))
;;
;;   (test-equal? "interp-with-env-uop-first-5"
;;                (interp-with-env-uop 
;;                  (op-first) 
;;                  (e-op (op-link) 
;;                        (e-op (op-link) (e-num 5) (e-empty (t-bool))) 
;;                        (e-empty (t-list (t-bool))))
;;                  my-empty-env)
;;                (v-list (list (v-num 5)))
;;   )
;;
;;   ;; INFO:
;;   ;; INTERPRETER 
;;   ;; REST 
;;
;;   (test-raises-interp-error? "interp-with-env-uop-rest-O"
;;                (interp-with-env-uop 
;;                  (op-rest) (e-num 5) my-empty-env))
;;
;;   (test-raises-interp-error? "interp-with-env-uop-rest-1"
;;                (interp-with-env-uop 
;;                  (op-rest) (e-empty (t-num)) my-empty-env))
;;
;;   (test-equal? "interp-with-env-uop-rest-2"
;;                (interp-with-env-uop 
;;                  (op-rest) 
;;                  (e-op (op-link) (e-num 3) (e-empty (t-bool)))
;;                  my-empty-env)
;;                (v-list empty))
;;
;;   (test-equal? "interp-with-env-uop-rest-3"
;;                (interp-with-env-uop 
;;                  (op-rest) 
;;                  (e-op (op-link) (e-str "3") (e-empty (t-bool)))
;;                  my-empty-env)
;;                (v-list empty))
;;
;;   (test-equal? "interp-with-env-uop-rest-4"
;;                (interp-with-env-uop 
;;                  (op-rest) 
;;                  (e-op (op-link) 
;;                        (e-lam 'a (t-num) (e-num 5)) 
;;                        (e-empty (t-bool)))
;;                  my-empty-env)
;;                (v-list empty))
;;
;;   (test-equal? "interp-with-env-uop-rest-5"
;;                (interp-with-env-uop 
;;                  (op-rest) 
;;                  (e-op (op-link) 
;;                        (e-op (op-link) (e-num 5) (e-empty (t-bool))) 
;;                        (e-empty (t-list (t-bool))))
;;                  my-empty-env)
;;                (v-list empty))
;;
;;
;;   ;; INFO:
;;   ;; INTERPRETER 
;;   ;; IS-EMPTY?
;;
;;   (test-raises-interp-error? "interp-with-env-uop-isempty-0"
;;                (interp-with-env-uop 
;;                  (op-is-empty) (e-num 5) my-empty-env))
;;
;;   (test-equal? "interp-with-env-uop-isempty-1"
;;                (interp-with-env-uop 
;;                  (op-is-empty) (e-empty (t-num)) my-empty-env)
;;                (v-bool #t))
;;
;;   (test-equal? "interp-with-env-uop-isempty-2"
;;                (interp-with-env-uop 
;;                  (op-is-empty) 
;;                  (e-op (op-link) (e-num 3) (e-empty (t-bool))) 
;;                  my-empty-env)
;;                (v-bool #f))
;;
;;   (test-equal? "interp-with-env-uop-isempty-3"
;;                (interp-with-env-uop 
;;                  (op-is-empty) 
;;                  (e-op (op-link) 
;;                        (e-lam 'a (t-num) (e-num 5)) 
;;                        (e-empty (t-bool)))
;;                  my-empty-env)
;;                (v-bool #f))
;;
;;   (test-equal? "interp-with-env-uop-isempty-4"
;;                (interp-with-env-uop 
;;                  (op-is-empty) 
;;                  (e-op (op-link) 
;;                        (e-op (op-link) (e-num 5) (e-empty (t-bool))) 
;;                        (e-empty (t-list (t-bool))))
;;                  my-empty-env)
;;                (v-bool #f))
;;
;;
;;   ;; INFO:
;;   ;; INTERPRETER
;;   ;; IF STATEMENT
;;
;;   (test-raises-interp-error? "interp-with-env-if-0"
;;                (interp-with-env-if
;;                  (e-num 5) (e-num 5) (e-num 5) my-empty-env))
;;
;;   (test-equal? "interp-with-env-if-1"
;;                (interp-with-env-if
;;                  (e-bool #t) (e-num 3) (e-str "") my-empty-env)
;;                (v-num 3))
;;
;;   (test-equal? "interp-with-env-if-3"
;;                (interp-with-env-if
;;                  (e-bool #t) (e-str "3") (e-bool #f) my-empty-env)
;;                (v-str "3"))
;;
;;   (test-equal? "interp-with-env-if-4"
;;                (interp-with-env-if
;;                  (e-bool #t) 
;;                   (e-bool #f) 
;;                   (e-lam 'a (t-num) (e-num 5)) 
;;                  my-empty-env)
;;                (v-bool #f))
;;
;;   (test-equal? "interp-with-env-if-5"
;;                (interp-with-env-if
;;                   (e-bool #t) 
;;                     (e-lam 'a (t-num) (e-num 5)) 
;;                     (e-empty (t-num))
;;                     my-empty-env)
;;                (v-fun 'a (e-num 5) my-empty-env))
;;
;;   (test-equal? "interp-with-env-if-6"
;;                (interp-with-env-if
;;                  (e-bool #t) 
;;                    (e-empty (t-num)) 
;;                    (e-num 5) 
;;                    my-empty-env)
;;                (v-list empty))
;;
;;   ;; INFO:
;;   ;; INTERPRETER
;;   ;; LAM STATEMENT 
;;
;;   (test-equal? "interp-with-env-lam-0"
;;                (interp-with-env-lam 
;;                  'a (t-num) (e-num 5) my-empty-env)
;;                (v-fun 'a (e-num 5) my-empty-env))
;;
;;   ;; INFO:
;;   ;; INTERPRETER
;;   ;; APP STATEMENT 
;;
;;   (test-raises-interp-error? "interp-with-env-app-1"
;;                (interp-with-env-app
;;                  (e-num 5) 
;;                  (e-num 5)
;;                  my-empty-env))
;;
;;   (test-equal? "interp-with-env-app-2"
;;                (interp-with-env-app
;;                  (e-lam 'a (t-num) (e-var 'a)) 
;;                  (e-str "5")
;;                  my-empty-env)
;;                (v-str "5"))
;;
;; )
;;
















;;   ;; FIXME: HIERONDER ZIJN TESTS EERDER VOOR 
;;   ;; DE PARSER DAN VOOR DE INTERP OF DESUGAR
;;
;;   ;; NOTE: Desugar tests
;;   (test-equal? "Works with and (both true)"
;;                (eval `{and true true}) (v-bool #t))
;;
;;   (test-equal? "Works with and (one false)"
;;                (eval `{and true false}) (v-bool #f))
;;
;;   (test-equal? "Works with and (both false)"
;;                (eval `{and false false}) (v-bool #f))
;;
;;   (test-equal? "Works with nested and"
;;                (eval `{and {and true true} true}) (v-bool #t))
;;
;;   (test-raises-error? 
;;     "And raises error with non-boolean arguments"
;;                (eval `{and 5 true}))
;;
;;   (test-raises-error? 
;;     "And raises error with wrong number of arguments"
;;                (eval `{and true}) )
;;
;;   (test-equal? "Works with or (both true)"
;;                (eval `{or true true}) (v-bool #t))
;;
;;   (test-equal? "Works with or (one true)"
;;                (eval `{or true false}) (v-bool #t))
;;
;;   (test-equal? "Works with or (both false)"
;;                (eval `{or false false}) (v-bool #f))
;;
;;   (test-equal? "Works with nested or"
;;                (eval `{or {or false true} false}) (v-bool #t))
;;
;;   (test-raises-error? 
;;     "Or raises error with non-boolean arguments"
;;                (eval `{or "foo" false}))
;;
;;   (test-raises-error? 
;;     "Or raises error with wrong number of arguments"
;;                (eval `{or false}))
;;
;;   (test-equal? "Works with let (simple case)"
;;                (eval `{let {x 5} x}) (v-num 5))
;;
;;   (test-equal? "Works with let (nested let)"
;;                (eval `{let {x 5} {let {y {+ x 2}} {+ x y}}}) 
;;                (v-num 12))
;;
;;   (test-equal? "Works with let (shadowing)"
;;                (eval `{let {x 5} {let {x 3} x}}) 
;;                (v-num 3))
;;
;;   (test-raises-error? 
;;     "Let raises error when symbol is invalid"
;;                (eval `{let {123 5} x}))
;;
;;   (test-raises-error? 
;;     "Let raises error with missing body"
;;                (eval `{let {x 5}}))
;;
;;   (test-raises-error? 
;;     "Let raises error with invalid binding value"
;;                (eval `{let {x "foo"} {+ x 1}}))
;;
;;   (test-equal? 
;;     "No error should be raised"
;;                (eval `{let {x 1}
;;                         {let {x {+ x 1}} 
;;                           x }}) 
;;                (v-num 2))
;;
;;   ;; (test-raises-error? "let-5"
;;   ;;              (eval `{let {x {lam y {x y}}}
;;   ;;                           {x 1}}))
;;   ;;
;;   ;; (test-raises-error? "let-6"
;;   ;;              (eval `{let {w {lam x {x x}}}
;;   ;;                     {ω ω}}))
;;
;;   ;; FIXME:
;;   ;; MAKE SURE YOU HAVE 100% CODE COVERAGE,
;;   ;; I DON'T THINK I HAVE THAT NOW.
;;
;;   ;; easy general tests / sanity checks
;;   ;; interp and parser checks
;;   (test-equal? "Works with Num primitive"
;;                (eval `2) (v-num 2))
;;
;;   (test-equal? "Works with Str primitive"
;;                (eval `"hello") (v-str "hello"))
;;
;;   (test-equal? "Works with Str primitive"
;;                (eval `true) (v-bool #t))
;;
;;   (test-equal? "Works with Bool primitive"
;;                (eval `false) (v-bool #f))
;;
;;   (test-true "Works with lambda"
;;                (v-fun? (eval `{lam x 5})))
;;
;;   ;; (test-equal? "Lambda application"
;;   ;;              (eval `{{lam x {+ x 1}} 4}) (v-num 5))
;;   ;;
;;   ;; (test-equal? "Nested lambda application"
;;   ;;              (eval `{{{lam x {lam y {+ x y}}} 3} 4}) 
;;   ;;              (v-num 7))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "Lambda creation raises error with invalid parameter"
;;   ;;              (eval `{lam 123 5}))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "Lambda creation raises error with missing body"
;;   ;;              (eval `{lam x}))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "Lambda application raises error when applied to non-function"
;;   ;;              (eval `{{+ 5 5} 3}))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "Lambda application raises error with wrong argument count"
;;   ;;              (eval `{{lam x {+ x 1}} }))
;;
;;   ;; (test-equal? "Works with If expression true"
;;   ;;              (eval `{if true 5 3}) (v-num 5))
;;   ;;
;;   ;; (test-equal? "Works with If expression false"
;;   ;;              (eval `{if false 5 3}) (v-num 3))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "If expression raises error on missing branches"
;;   ;;              (eval `{if true 5}))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "If expression raises error on invalid condition"
;;   ;;              (eval `{if 5 5 3}))
;;   ;;
;;   ;; (test-equal? "Works with + operand"
;;   ;;              (eval `{+ 5 3}) (v-num 8))
;;   ;;
;;   ;; (test-equal? "Nested addition works"
;;   ;;              (eval `{+ 1 {+ 2 3}}) (v-num 6))
;;
;;   ;; (test-raises-error? 
;;   ;;   "Addition raises error with invalid arguments"
;;   ;;              (eval `{+ 5 "foo"}))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "Addition raises error with wrong number of arguments"
;;   ;;              (eval `{+ 5}))
;;   ;;
;;   ;; (test-equal? "Works with ++ operand"
;;   ;;              (eval `{++ "foo" "bar"}) (v-str "foobar"))
;;   ;;
;;   ;; (test-equal? "Nested string concatenation"
;;   ;;              (eval `{++ "hello" {++ " " "world"}}) 
;;   ;;              (v-str "hello world"))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "String concatenation raises error with invalid types"
;;   ;;              (eval `{++ "foo" 5}))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "String concatenation raises error with wrong number of arguments"
;;   ;;              (eval `{++ "foo"}))
;;   ;;
;;   ;; (test-equal? "Works with num= operand false"
;;   ;;              (eval `{num= 1 2}) (v-bool #f))
;;   ;;
;;   ;; (test-equal? "Works with num= operand true"
;;   ;;              (eval `{num= 1 1}) (v-bool #t))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "Numeric equality raises error with invalid types"
;;   ;;              (eval `{num= "foo" 1}))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "Numeric equality raises error with wrong number of arguments"
;;   ;;              (eval `{num= 1}))
;;   ;;
;;   ;; (test-equal? "Works with str= operand false"
;;   ;;              (eval `{str= "foo" "bar"}) (v-bool #f))
;;   ;;
;;   ;; (test-equal? "Works with str= operand false"
;;   ;;              (eval `{str= "foo" "foo"}) (v-bool #t))
;;   ;;
;;   ;; (test-equal? "Works with str= operand false"
;;   ;;              (eval `{str= "foo" "foo"}) (v-bool #t))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "String equality raises error with invalid types"
;;   ;;              (eval `{str= 5 "foo"}))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "String equality raises error with wrong number of arguments"
;;   ;;              (eval `{str= "foo"}))
;;   ;;
;;   ;; (test-raises-error?  
;;   ;;   "function applicant unassigned results in error"
;;   ;;              (eval `{f 5}))
;;   ;;
;;   ;; (test-raises-error? 
;;   ;;   "Function application raises error with extra arguments"
;;   ;;              (eval `{f 5 6}))
;;
;;   ;; NOTE: tests from README
;;
;;   (test-raises-error? "01.R1" (eval `{str= {+ 5 "bad"}}))
;;   (test-raises-error? "01.R2" (eval `{++ false {+ "bad" 6}}))
;;   (test-raises-error? "01.R3" (eval `{"not function" {+ 7 "bad"}}))
;;
;;
;;   ;; NOTE: Following are test cases from the lectures.
;;   ;; 01.L arithmatics tests
;;
;;   (test-equal? "01.L1"
;;     (eval `{+ {+ 1 2} 3}) (v-num 6))
;;   (test-equal? "01.L2"
;;     (eval `{+ 1 {+ 2  3}}) (v-num 6))
;;   (test-equal? "01.L3"
;;     (eval `{+ 1 {+ {+ 2 3} 4}}) (v-num 10))
;;
;;   ;; fails because of floating point imprecision
;;   ;; (test-equal? "01.L4"
;;   ;;  (eval `{+ 0.1 0.2}) (v-num 0.3))
;;   ;; (test-equal? "01.L5"
;;   ;;  (eval `{+ 0.1 0.2}) (v-num 1/3))
;;
;;   ;; NOTE:
;;   ;; 04.L booleans tests
;;
;;   (test-equal? "04.L1"
;;     (eval `{if  true 10 -10}) (v-num 10))
;;
;;   (test-equal? "04.L2"
;;     (eval `{if false 1 2}) (v-num 2))
;;
;;   (test-equal? "04.L3"
;;     (eval `{if false 1 true}) (v-bool true))
;;
;;   (test-raises-error? "04.L4"
;;     (eval `{+ 1 true}))
;;
;;   (test-raises-error? "04.L5"
;;     (eval `{+ false 10}))
;;
;;   ;; NOTE:
;;   ;; 05.L local binding tests
;;
;;   ;; `{let1 {x 1} {+ x x}} => 2
;;   ;; `{{lam x {+ x x}} 1}  => 2
;;   (test-equal? "05.L1"
;;     (eval `{{lam x {+ x x}} 1}) (v-num 2))
;;
;;   ;; `x => error: x not bound
;;   (test-raises-error? "05.L2" 
;;     (eval `x ))
;;
;;   ;; `{+ {let1 {x 1} x} x}  => error: x not bound
;;   ;; `{+ {{lam x x} 1}  x}  => error: x not bound
;;   (test-raises-error? "05.L3"
;;     (eval `{+ {{lam x x} 1}  x}))
;;
;;   ;; `{let1 {x 1} {+ {let1 {x 2}   x}  x}}    => 3
;;   ;; `{{lam x     {+ {{lam x -> x} 2}  x}} 1} => 3
;;   (test-equal? "05.L4"
;;     (eval `{{lam x {+ {{lam x x} 2} x}} 1}) (v-num 3))
;;
;;   ;; NOTE: 
;;   ;; 06.L function tests
;;
;;   ;; `{let1 {f {lambda x {+ x x}}} {f 3}} => 6
;;   ;; `{{lam f {f 3}} {lambda x {+ x x}}}  => 6 
;;   (test-equal? "06.L1"
;;     (eval `{{lam f {f 3}} {lam x {+ x x}}}) 
;;     (v-num 6))
;;
;;   ;; `{let1 {x 1}
;;   ;;        {let1 {f {lambda y x}}
;;   ;;              {let1 {x 2}
;;   ;;                    {f 10}}}}
;;   ;; `{{\x -> {{\f -> {{\x -> {f 10}} 2}}{lam y x}}}1}
;;   (test-equal? "06.L2"
;;     (eval `{{lam x  {{lam f {{lam x {f 10}} 2}} {lam y x}}} 1}) 
;;     (v-num 1))
;;
;;   ;; `{{let1 {x 3}
;;   ;;         {lambda y {+ x y}}}
;;   ;;   4}
;;   ;; `{{{\x -> {\y -> {+ x y}}}3}4}
;;   (test-equal? "06.L3"
;;     (eval `{{{lam x {lam y {+ x y}}}3}4}) (v-num 7))
;;
;;   ;; NOTE:  
;;   ;; 07.L static scope tests
;;
;;   ;; consider this SMoL program:
;;   ;; ((let ([y 3])
;;   ;;    (lambda (y) (+ y 1)))
;;   ;;  5)
;;   ;;  `{{{\y -> {\y {+ y 1}}} 3} 5}
;;   (test-equal? "06.L4"
;;     (eval `{{{lam y {lam y {+ y 1}}} 3} 5}) (v-num 6))
;;
;;   ;; NOTE: Following test cases extracted from SMoL tutorials
;;   ;; 15.S lambda expressions
;;
;;   ;; (deffun (f x)
;;   ;;    (lambda (y) (+ x y)))
;;   ;; (defvar x 0)
;;   ;; ((f 2) 1)
;;   (test-equal? "Lambda test 1"
;;     (eval `{{{{ lam x { lam x {lam y {+ x y}}}} 0} 2} 1}) (v-num 3))
;;
;;   ;; (deffun (foobar)
;;   ;;    (defvar n 0)
;;   ;;    (lambda ()
;;   ;;      (set! n (+ n 1))
;;   ;;      n))
;;   ;; (defvar f (foobar))
;;   ;; (defvar g (foobar))
;;   ;; (f)
;;   ;; (f)
;;   ;; (g)
;;
;; ;; {\f -> {\g -> {+ {+ {f} {f}} {g}}} {foobar}} {foobar}
;; ;; NOTE: 0 as argument means no variable (void)
;;
;; ;; (test-equal? "Lambda test 2"
;; ;;   (eval `{{lam f {{lam g {+ {f 0}  0 }} {{lam _ {{lam n {lam _ {+ n 1}}} 0}} 0}}} {{lam _ {{lam n {lam _ {+ n 1}}} 0}} 0}})
;; ;;   (v-num 1)
;; ;; )
;; ;;
;; ;; FIXME:
;; ;; no clsoure...
;; ;; due to my s-expression?
;; ;; due to my language? 
;; ;; due to the fact that this is not possible in such a language?
;; ;;
;; ;;(test-equal? "Lambda test 2"
;; ;;  (eval `{{lam f {{lam g {+ {f 0} {f 0}}} {{lam _ {{lam n {lam _ {+ n 1}}} 0}} 0}}} {{lam _ {{lam n {lam _ {+ n 1}}} 0}} 0}})
;; ;;  (v-num 3)
;; ;;)
;; ;;
;; ;; (test-equal? "Lambda test 3"
;; ;;   (eval `{{lam f {{lam g {+ {f 0} {g 0}}} {{lam _ {{lam n {lam _ {+ n 1}}} 0}} 0}}} {{lam _ {{lam n {lam _ {+ n 1}}} 0}} 0}})
;; ;;   (v-num 2)
;; ;; )
;;




