# Introduction

In past assignments you've written an interpreter for miniPlait and a type-checker for
Typed miniPlait. Now you're going to combine the two into an interpreter for Typed miniPlait.

# Assignment

As in [Interpreter](../1-interp/), we have
provided the `parse` function for you.

You will be re-implementing `desugar`, `interp` and `type-of`, with the same general requirements.
So you should be able to copy-and-paste the vast majority of your code. The difficulty
of this assignment is in making these functions work together
correctly. Also, this assignment uses *Typed* miniPlait, the same language as in
[Type Checker](../3-tcheck/) (well, not *exactly*
the same; see the Additional Notes section.), but you wrote your interpreter for untyped
miniPlait, so you will need to extend your interpreter.

In your final implementation, the evaluation pipeline will work like this:

1. The input `S-Exp` is parsed into an `Expr+` with the provided `parse` function.
2. The `Expr+` is passed through `desugar`, to create a desugared `Expr`.
3. The desugared `Expr` is type-checked by passing it through `type-of`. The result of
`type-of` is the `Type` of the given `Expr`. We just confirm that it
*has* a type; if it does not, we signal a type error. Otherwise:
4. The desugared `Expr` is passed to `interp` to produce a final value.

In order to simplify things, and keep you on the right track, we've split this assignment
into 3 phases.

## Phase 1 : Updating interp

In the first phase, you will modify your work on the
[Interpreter](../1-interp/) assignment to
interpret the *syntax* of Typed miniPlait, but with the same, “untyped” *semantics* of
the interpreter. Thus, some expressions
(`let` and `lambda` expressions, specifically) passed to your interpreter will now
have type annotations, but you will *ignore* the annotations.

Of course, you will still have safety checks, just as before.
For example, if a program tries to add
a number and a string, `interp` should still throw an error because those types don't make
sense for that operation. But you will not try to simulate all the
checks that the type-checker does.
Thus,
`interp` should not immediately throw an error when applying a function with a `Num`-annotated
formal parameter to a string. (If that function then tries to add its input to a number,
*then* `interp` would have to throw an error.)

Additionally, for reasons that will become clear in phase 3, **all errors produced by your `interp`
function must now come from the provided `raise-interp-error` function**.

## Phase 2 : Updating type-of

In the second phase, you will modify your work on
[Type Checker](../3-tcheck/) to be compatible
with this assignment. This one should be much simpler than phase 1: you need to make
your `type-of` function compatible with the altered `let` syntax, and should remove the
cases that are now handled by `desugar`.

Additionally, like in phase 1, **all errors produced by your type-of function must now
come from the provided `raise-type-error` function**.

## Phase 3 : Putting them together

Finally, you will combine `desugar`, `interp` and `type-of` in one file, as described in the
evaluation pipeline. After doing so, many of your `interp` errors will now be caught
in `type-of`, so you should **remove all unnecessary error-handling code from your `interp`
function**.

Take care though: `type-of` can't catch every error!

Additionally, combining them as described in the evaluation pipeline
will slightly change
the semantics of the language. Remember to update your tests accordingly.

## Reflection (Short report)

By introducing a type-checker, you've eliminated the need for certain runtime checks
and error handling in your `interp` function. We'd like you to reflect on this modification
in a short write-up. See the questions in [REPORT.md](./REPORT.md).

## Additional notes

Here are some more points to keep in mind.

First: Let expressions in this assignment have a slightly different syntax than they did in
type-checker. They now require a type annotation on the variable binding, like this:

```racket
(eval `(let (x 4 : Num) (+ x x)))
```

In
[Type Checker](../3-tcheck/) we could omit this
annotation because we could determine the type of the actual parameter by calling `type-of`
recursively. We *could* still omit the annotation, but it would require complicating our
evaluation pipeline. Why? (Hint:
[Type Checker](../3-tcheck/) didn't have a
desugaring step.)

Second: There are now two kinds of environments you need to work with. `Env` is for tracking
variable bindings in `interp`, and `TEnv` is for tracking variable *types* in `type-of`.
Don't get them confused!

## Errors

To raise an error found in `type-of`, you should call the `raise-type-error` function
with a helpful message, like so:

```racket
(raise-type-error "can't add numbers to strings")
```

Similarly, to raise an error found in `interp`, you should call the `raise-interp-error` function.

Both kinds of errors can (and should) be explicitly tested for in your tests file,
using the `test-raises-type-error?` and `test-raises-interp-error?` constructions.

# Testing

You will be writing separate test files for each phase, so you can get feedback as you
go. You can copy-and-paste most of your tests from
[Interpreter](../1-interp/) for testing
phases 1 and 3, and similarly you can copy-and-paste most of your tests from
[Type Checker](../3-tcheck/) for testing phase 2.

But remember:

- Phase 1 adds new functionality to the interpreter that you must add new tests for.
- You will need to add type annotations to the `let` expressions in your tests to avoid parser errors.
- Phase 3 *removes* some functionality from the interpreter, so some of your tests will have to be changed to account for that.
- You should only be testing against the `eval` and `type-check` functions.

# Grammar

The modified grammar of Typed miniPlait is as follows:

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
         | (and <expr> <expr>)
         | (or <expr> <expr>)
         | <id>
         | (<expr> <expr>)
         | (lam (<id> : <type>) <expr>)
         | (let (<id> <expr> : <type>) <expr>)
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

## Abstract Syntax

The `Value` type is the same as in [Interpreter](../1-interp/),
but is repeated here for convenience. The `Expr+` type is almost identical to the one in
[Type Checker](../3-tcheck/), but `let` expressions
now include a type.

```racket
(define-type Type
  (t-num)
  (t-bool)
  (t-str)
  (t-fun [arg-type : Type] [return-type : Type])
  (t-list [elem-type : Type]))

(define-type Value
  (v-num [value : Number])
  (v-bool [value : Boolean])
  (v-str [value : String])
  (v-fun [param : Symbol]
         [body : Expr]
         [env : Env])
  (v-list [vals : (Listof Value)]))

(define-type Expr+
  (e-num+ [value : Number])
  (e-bool+ [value : Boolean])
  (e-str+ [value : String])
  (e-op+ [op : Operator]
         [left : Expr+]
         [right : Expr+])
  (e-un-op+ [op : UnaryOperator]
            [expr : Expr+])
  (e-if+ [cond : Expr+]
         [consq : Expr+]
         [altern : Expr+])
  (e-lam+ [param : Symbol]
          [arg-type : Type]
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
             [type : Type]
             [body : Expr+])
  (e-empty+ [elem-type : Type]))

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

# Starter Code

For phase 1, update the code in `updated-interp.rkt` and add your tests in `updated-interp-tests.rkt`.

For phase 2, update the code in `updated-tcheck.rkt` and add your tests in `updated-tcheck-tests.rkt`.

For phase 3, update the code in `tynterp.rkt` and add your tests in `tynterp-tests.rkt`.

For the reflection questions, add your answers to `REPORT.md`.

# What We Will Check

Post-deadline, we will review and test only the above-mentioned files (other files will be ignored).
