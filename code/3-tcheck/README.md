# Introduction

In this assignment, you will extend miniPlait with static types and implement a static type checker for it.

# Assignment

As in [Interpreter](../1-interp/), we have provided a function `parse`, which consumes an expression in miniPlait's concrete syntax and returns the abstract syntax representation (`Expr`) of that expression.

You will implement one function called `type-of`:

```
type-of :: Expr -> Type
```

that consumes a miniPlait program in abstract syntax form. If the program is well-typed, `type-of` returns the `Type` of that program; otherwise, it raises an exception.

Once you have implemented `type-of`, you should use the provided `type-check` function (analogous to `eval` from [Interpreter](../1-interp/)) to write test cases for your type checker in your testing file.

For simplicity, our Typed version of miniPlait does not have syntactic sugar, so `and` and `or` have been removed from the language.

# Features to Implement

## Type Environment

The type language you will work with is

```racket
(define-type Type
  (t-num)
  (t-bool)
  (t-str)
  (t-fun [arg-type : Type]
         [return-type : Type])
  (t-list [elem-type : Type]))
```

which, respectively, represent the types of numbers, Booleans, strings, (one-argument) functions, and (homogenous) lists.

Just as how [Interpreter](../1-interp/) had an `Env` for mapping identifiers to values, your interpreter should use a type environment (`TEnv`) to keep track of the _types_ of identifiers in scope.

```racket
(define-type-alias TEnv (Hashof Symbol Type))
```

In `type-of`, if the program binds an identifier that is already bound, the new binding should take precedence. This is known as _identifier shadowing_. The new binding shadows the existing binding.

## `let`

`let` is a new expression which should accept a single identifier-value pair and a body. `let` evaluates the value, binds it to the identifier, and evaluates the body with the newly bound identifier in scope. For example, the following should evaluate to `3`:

```racket
(let (x 1) (+ x 2))
```

`let` should disallow recursive definitions. That is, in `(let (<id> <expr>) <body>)`, `<id>` should be bound in `<body>` but not in `<expr>`.

## Lists

Our Typed version of miniPlait now contains support for
lists via the constant `empty` and the operations
`link`, `is-empty`, `first`, and `rest`. Lists in miniPlait
are _homogeneous_: all elements in the list must have the
same type.

A question to briefly consider: What is the `Type` of the
empty list? It’s _polymorphic_: it can be a list of any
type at all! Because it has no elements, there’s nothing
to constrain its type. However, because our type checker
is not polymorphic, we handle this with a simple expedient:
we require that every empty list be annotated with a type
for the elements (that will eventually be linked to it).
Naturally, the elements that eventually are linked to it
must be consistent with that annotated type.

Thus, our typed list semantics are as follows:

- `empty`

    `(empty : t)` makes an empty list whose elements have type `t`.

- `link :: t, (List t) -> (List t)`

    `(link x y)` appends the element `x` to the front of the list `y`.

- `first :: (List t) -> t`

    `(first x)` returns the first element of `x`.

- `rest :: (List t) -> (List t)`

    `(rest x)` returns the list `x` except for the first element of `x`.

- `is-empty :: (List t) -> Bool`

    `(is-empty x)` returns `true` if `x` is `empty`; otherwise, it returns false.

Whenever these type signatures are violated,
the type checker should raise an error.

Error-checking `link` should occur in the following manner:
If the type of the second argument to `link` isn't a
`(List t)`, the `(error 'TypeError "error message here")`
should be raised. If the second argument to `link` is
a `(List t)` but the type of the first argument is
not `t`, then `(error 'TypeError "error message here")`
should be raised as well. For example,

```racket
(link "hello" 3)
(link 2 (empty : Bool))
```

should all raise `(error 'TypeError "error message here")`.

## Error Catching

Your type-checker should raise a generic Racket error in
all scenarios that types do not match. When raising an
error, follow the syntax below:

`(error 'TypeError "error message here")`

Racket's "error" function should be followed by a symbol,
which is preceded by a single quotation mark. In this case,
we put a string symbol "TypeError" after the error call,
which allows us to raise an error, signifying that a
TypeError has occurred. Here is the
[Documentation](https://docs.racket-lang.org/plait/Predefined_Functions_and_Constants.html#%28def._%28%28lib._plait%2Fmain..rkt%29._error%29%29)
for the error function call in plait language.

The error your type-checker will raise are just like the error from [Interpreter](../1-interp/), but with a type instead of a value.

Your type-checker should type-check by performing a _post-order traversal_ of the AST: first, traverse all of the children of an expression from left to right, then check the expression itself.

# Grammar

The grammar of Typed miniPlait is as follows:

```
<expr> ::= <num>
         | <string>
         | true
         | false
         | (+ <expr> <expr>)
         | (++ <expr> <expr>)
         | (num= <expr> <expr>)
         | (str= <expr> <expr>)
         | (if <expr> <expr> <expr>)
         | <id>
         | (<expr> <expr>)
         | (lam (<id> : <type>) <expr>)
         | (let (<id> <expr>) <expr>)
         | (first <expr>)
         | (rest <expr>)
         | (is-empty <expr>)
         | (empty : <type>)
         | (link <expr> <expr>)

<type> ::= Num
         | Str
         | Bool
         | (List <type>)
         | (<type> -> <type>)
```

Our `parse` function expects and enforces spaces around `:` and `->`, so keep that in mind when you're writing test cases.

## Abstract Syntax

Refer to [Type Environment](#type-environment) for the definitions of `TEnv` and `Type`.

```racket
(define-type Expr
  (e-num [x : Number])
  (e-bool [x : Boolean])
  (e-str [x : String])
  (e-op [op : Operator]
        [left : Expr]
        [right : Expr])
  (e-un-op [op : UnaryOperator]
           [expr : Expr])
  (e-if [cond : Expr]
        [consq : Expr]
        [altern : Expr])
  (e-lam [param : Symbol]
         [arg-type : Type]
         [body : Expr])
  (e-app [func : Expr]
         [arg : Expr])
  (e-id [name : Symbol])
  (e-let [id : Symbol]
         [value : Expr]
         [body : Expr])
  (e-empty [elem-type : Type]))

(define-type Operator
  (op-plus)
  (op-append)
  (op-num-eq)
  (op-str-eq)
  (op-link))

(define-type UnaryOperator
  (op-first)
  (op-rest)
  (op-is-empty))
```

# Testing Guidelines

For the purposes of testing, we have defined a `type-check` function that calls `parse` and `type-of` for you. `type-check` consumes an expression in miniPlait's concrete syntax (`S-Exp`) and returns a miniPlait `Type`:

```
type-check :: S-Exp -> Type
```

You should use `type-check` in your testing file when writing test cases. You should not directly test `type-of` in your testing file.

# Starter Code

We've provided starter code for your implementation at
`type-checker.rkt` and support code at `support.rkt`. You are not
allowed to change the signature of `type-check` and `type-of`, but you
are welcome to add any helper functions that you need for your implementation.

We've also provided a stencil for your `type-check` test cases at `type-checker-tests.rkt` and testing support code at `test-support.rkt`. You should check that you can run your `type-checker-tests.rkt` file successfully in DrRacket before submitting—if you can't, it means that a definition is missing or you're trying to test a function that you shouldn't be testing.

# What We Will Check

Post-deadline, we will review and test the following files in your repository (other files will be ignored):

- `type-checker.rkt`, which should contain the implementation of your type checker.

- `type-checker-tests.rkt`, which should test your type checker.
