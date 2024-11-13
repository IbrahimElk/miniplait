# Introduction

For this assignment, you will write a desugarer for the miniPlait language introduced in
[Interpreter](../1-interp/). This will let
you add new syntax forms without having to change the interpreter.

# Assignment

As in [Interpreter](../1-interp/), we have provided a parsing function which
consumes an expression in the miniPlait language's concrete syntax, `S-Exp`, and returns
the abstract syntax representation of that expression. However, we want to add `and`,
`or`, and `let` expressions to the concrete syntax, and the parser from [Interpreter](../1-interp/)
doesn't know how to handle those. The new syntax also means the parser can't convert
to an `Expr` right away, since the `Expr` type can't directly represent these new syntax
forms.

We have therefore provided you with a new parser, which outputs abstract syntax as a new type,
`Expr+`:

```
parse+ :: S-Exp -> Expr+
```

`Expr+` is very similar to the `Expr` from [Interpreter](../1-interp/). However,
it includes three new constructors, `sugar-and`, `sugar-or`, and `sugar-let`. These represent
the new syntactic sugar expressions. Also, to avoid confusion, the constructors it shares
with `Expr` have been renamed to `e-num+`, `e-app+`, and so on.

You will implement the `desugar` function:

```
desugar :: Expr+ -> Expr
```

which consumes an abstract syntax tree (i.e. an `Expr+`, as returned
by `parse+`), replaces all instances of syntactic sugar with
desugared equivalents, and returns the result.

Observe that an expression may have *multiple different correct
desugarings*. (A desugaring is “correct” if, when the result is
evaluated, it produces the desired result.)
Therefore, you must be careful in how you write tests for this assignment. For example, any test
that follows this pattern:

```
(test-equal? "test name" (desugar ...) ...)
```

is _invalid!_ If you were to run this test on another `desugar` implementation
that happens to produce a different correct desugared expression, it would fail.

To judge whether your `desugar` implementation is correct, you will need your
`interp` implementation. For your convenience, the `desugar.rkt` code stencil
automatically imports your interpreter; make sure it's in the same directory!
You will use the provided `eval` function (which wraps around `desugar`, `interp`, and
`parse+`) to write test cases.

# Features to Implement

> Note: during the lectures we also studied Racket macros to implement syntactic
sugar. However, we are not asking you to use Racket macros for
anything in this assignment.

As described previously, miniPlait contains several forms of syntactic sugar: `and`,
`or`, and `let`. `desugar` should convert `sugar-and`, `sugar-or`, and `sugar-let`
`Expr+`s into functionally equivalent, non-sugar `Expr`s.

There are multiple implementation strategies for `desugar`. Be sure to test it
well: it's easy to miss some details when desugaring!

## `and` and `or`

- `and` consumes two boolean expressions. It evaluates to `true` if both boolean
  expressions are true; otherwise, it evaluates to `false`.

- `or` consumes two boolean expressions. It evaluates to `true` if at least one
  boolean expression is true; otherwise, it evaluates to `false`.

`desugar` should convert `sugar-and` and `sugar-or` `Expr+`s in such a way that,
when `interp` interprets the desugared code, `and` and `or`
**short-circuit**. In `and` expressions, this means that if the first argument
of `and` evaluates to `false`, the second argument to `and` is not evaluated and
the `and` expression evaluates to `false`. (Similarly, if the first argument of
`or` evaluates to `true`, the second argument to `or` should not be evaluated.)
Thus, the second argument of a short-circuited expression should never throw an
error.

## `let`

`let` should accept a single variable-value pair and a body. `let` evaluates
the value, binds it to the variable, and evaluates the body with the newly bound
variable in scope. For example, the following should evaluate to `3`:

```
(let (x 1) (+ x 2))
```

`let` should not support recursive definitions. That is, in
`(let (<var> <expr>) <body>)`, `<var>` should be bound in `<body>` but not in
`<expr>`.

> The desugaring of `sugar-let` may not be obvious, so here's a hint: What `Expr`(s)
> allow us to extend the variables bound within a given environment?

# Grammar

The (expanded) grammar of miniPlait is as follows:

```
<expr> ::= <num>
         | <string>
         | <var>                        # variable (a.k.a. identifier)
         | true
         | false
         | (+ <expr> <expr>)
         | (++ <expr> <expr>)
         | (num= <expr> <expr>)
         | (str= <expr> <expr>)
         | (if <expr> <expr> <expr>)
         | (and <expr> <expr>)
         | (or <expr> <expr>)
         | (let (<var> <expr>) <expr>)
         | (lam <var> <expr>)           # anonymous function
         | (<expr> <expr>)             # function application
```

## Abstract Syntax

```
(define-type Value
  (v-num [value : Number])
  (v-str [value : String])
  (v-bool [value : Boolean])
  (v-fun [param : Symbol]
         [body : Expr]
         [env : Env]))

(define-type Expr+
  (e-num+ [value : Number])
  (e-str+ [value : String])
  (e-bool+ [value : Boolean])
  (e-op+ [op : Operator]
        [left : Expr+]
        [right : Expr+])
  (e-if+ [cond : Expr+]
        [consq : Expr+]
        [altern : Expr+])
  (e-lam+ [param : Symbol]
         [body : Expr+])
  (e-app+ [func : Expr+]
         [arg : Expr+])
  (e-var+ [name : Symbol])
  (sugar-and [left : Expr+]
             [right : Expr+])
  (sugar-or [left : Expr+]
            [right : Expr+])
  (sugar-let [var : Symbol]
             [value : Expr+]
             [body : Expr+]))
```

## Testing Guidelines

For the purposes of testing, we have defined an `eval` function like the one from
[Interpreter](../1-interp/), that additionally
passes the parsed `Expr+` through your `desugar` function before interpreting it.

```
eval :: S-Exp -> Value
```

You should use `eval` in your testing file when writing test cases. You should not directly
test `desugar` individually in your test file (though you are welcome to and encouraged
to individually test your functions in your code file). There's good reason for this:
there is more than one correct desugaring, so any tests you write may be implementation-specific.
(And, of course, your submitted test cases should indirectly test desugaring, because
you should test that `and` and `or` let work correctly.)

Of course, since `eval` relies on both your `interp` and `desugar` functions, test
failures could come from either implementation. If you can't figure out a bug, you may
want to double-check that your `interp` is correct - try writing more test cases for
the [Interpreter](../1-interp/) assignment.

# Starter Code

To facilitate testing, the starter code for this assignment is the same as
the one for [Interpreter](../1-interp/).

We've provided starter code for your implementation at
`desugar.rkt` and support code at `desugar-support.rkt`. You are not
allowed to change the signature of `eval` or `desugar`, but you
are welcome to -- and might need to -- add helper functions for your implementation.

We've also provided a stencil for your `eval` test cases at `desugar-tests.rkt` and
testing support code at `test-support.rkt`. You should check that you can run your
`desugar-tests.rkt` file successfully in DrRacket before submitting—if you can't,
it means that a definition is missing or you're trying to test a function that you
shouldn't be testing (e.g. a helper function or `desugar` directly).

**Do not** modify the contents of `desugar-support.rkt` and `test-support.rkt`.

# What We Will Check

(Same as for [Interpreter](../1-interp/))