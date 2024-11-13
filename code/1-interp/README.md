# Introduction

For this assignment, you will write an interpreter for a scaled-down version
of the plait language ("miniPlait") described below.

# Assignment

We have provided a function `parse` which consumes an expression in the miniPlait
language's concrete syntax, `S-Exp`, and returns the abstract syntax
representation of that expression (an `Expr`).

```
parse :: S-Exp -> Expr
```

`parse` only accepts expressions that follow miniPlait's [grammar](#grammar).

You will implement a new function: `interp`.

- `interp :: Expr -> Value`

    which consumes an abstract syntax tree (i.e. an `Expr`) and returns a miniPlait `Value`.

    `interp` should evaluate programs by performing a
    _post-order traversal_ of the abstract syntax tree (AST): first, evaluate
    all of the children of an expression from left to right, then evaluate the
    expression itself. This makes it unambiguous which error to
    raise if there are multiple errors in the AST.

    > Why evaluate our expressions from left to right? One might say we've chosen
    > this as a matter of convention, but ultimately the choice is completely
    > arbitrary. Strictly speaking, we could define our
    > language to evaluate sub-expressions from right to left and that would be just
    > fine. What's important is that an explicit evaluation order choice is
    > made so the language has clearly defined semantics.

Once you have implemented `interp`, you should use the provided `eval` function
(which wraps around `interp` and `parse`) to write test cases for your interpreter.

## Errors

For throwing errors you can use Racket's error message convention which looks like
`(error <symbol> <message string>)` where a symbol is written as a single quote
followed by a variable.  Such a symbol name can look like `'interp-error` (`'abc` or
`'xyz` would also work but we recommend keeping useful names). Here is an example of
how you can throw an error:

``` 
(error 'interp-error "unbound variable was found")
```

Some examples of expressions that should raise errors are:

```
(str= (+ 5 "bad") "hello")
(++ false (+ "bad" 6))
("not function" (+ 7 "bad"))
```

These should all throw the standard error as per the convention specified above. However, we recommend having useful messages in the strings to keep track of the types of errors and edge cases you are covering; this also comes in handy when debugging!

# Features to Implement

## Environment

Your interpreter should use an environment, `Env`, to keep track of the `Value`s
of variables in scope.

`(define-type-alias Env (Hashof Symbol Value))`

Since `Env` is a
[`Hashof`](https://docs.racket-lang.org/plait/Types.html#%28form._%28%28lib._plait%2Fmain..rkt%29._.Hashof%29%29),
you can use Plait’s built-in hash table functions on your `Env`.

> For your environment, make sure you use
[`hash`](https://docs.racket-lang.org/plait/Predefined_Functions_and_Constants.html?q=hash#%28def._%28%28lib._plait%2Fmain..rkt%29._hash%29%29),
which creates _immutable_ hash tables! What happens if you use
[`make-hash`](https://docs.racket-lang.org/plait/Predefined_Functions_and_Constants.html?q=hash#%28def._%28%28lib._plait%2Fmain..rkt%29._make-hash%29%29),
which creates _mutable_ hash tables instead? Try replacing one with the other
and see. If none of your tests fail, you aren’t testing enough! You should have
at least one failing test, if not several, when you make this switch.

`interp` should allow _variable shadowing_, meaning that if you bind a
variable that is already bound, the new binding takes precedence. When in
doubt, your interpreter should behave just as SMoL would.

When `interp` encounters an unbound variable, `interp` should raise an error.

## Binary Operators

miniPlait includes binary addition (`+`) and number equality testing (`num=`), as
well as string appending (`++`) and string equality testing (`str=`).

In place of having separate syntactic forms for each of `+`, `num=`, `++`, and
`str=`, `parse` converts these operators into a single AST datatype variant,
`e-op`, which denotes the operation to use via an `Operator` variant:

```
(define-type Operator
  (op-plus)
  (op-append)
  (op-str-eq)
  (op-num-eq))
```

When you implement these operators, you should use Plait's
[`+`](https://docs.racket-lang.org/plait/Predefined_Functions_and_Constants.html#%28def._%28%28lib._plait%2Fmain..rkt%29._%2B%29%29) for `op-plus`,
[`string-append`](https://docs.racket-lang.org/plait/Predefined_Functions_and_Constants.html#%28def._%28%28lib._plait%2Fmain..rkt%29._string-append%29%29)
for `op-append`,
[`string=?`](https://docs.racket-lang.org/plait/Predefined_Functions_and_Constants.html#%28def._%28%28lib._plait%2Fmain..rkt%29._string~3d~3f%29%29) for `op-str-eq`,
and [`=`](https://docs.racket-lang.org/plait/Predefined_Functions_and_Constants.html#%28def._%28%28lib._plait%2Fmain..rkt%29._~3d%29%29) for `op-num-eq`.

Evaluation should also raise an error for non-numeric values
passed to `+` and `num=` operations, and for non-string values passed to `++`
and `str=` operations. Here we throw an error when the operator is receiving the wrong type of value, for example:

```
(+ true "string")
```

## Conditionals

`if`-expressions in miniPlait have three parts:

  - `cond`, which should evaluate to a Boolean `Value`

  - `consq`, which evaluates if `cond` evaluated to `true`

  - `altern`, which evaluates if `cond` evaluated to `false`

`if` statements should short-circuit (i.e. only evaluate the relevant branch).
If `cond` evaluates to a non-Boolean `Value`, an error should be raised.

## Functions

Functions in miniPlait are unary (i.e. they take exactly 1 argument). Here’s two
examples of functions and their applications:

```
((lam x (+ x 3)) 2)

((lam y 5) 1)
```

> These should both evaluate to 5.

It’s possible that when attempting to perform a function application, the value
in the function position isn’t actually a function; e.g., you might have `(1
2)`. In this case you should raise an error as well.

# Grammar

The grammar of miniPlait is as follows:

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
         | (lam <var> <expr>)           # anonymous function
         | (<expr> <expr>)             # function application
```

## Abstract Syntax

Refer to [Environment](#environment) for the definition of `Env` and
[Binary Operators](#binary-operators) for the definition of `Operator`.

```
(define-type Value
  (v-num [value : Number])
  (v-str [value : String])
  (v-bool [value : Boolean])
  (v-fun [param : Symbol]
         [body : Expr]
         [env : Env]))

(define-type Expr
  (e-num [value : Number])
  (e-str [value : String])
  (e-bool [value : Boolean])
  (e-op [op : Operator]
        [left : Expr]
        [right : Expr])
  (e-if [cond : Expr]
        [consq : Expr]
        [altern : Expr])
  (e-lam [param : Symbol]
         [body : Expr])
  (e-app [func : Expr]
         [arg : Expr])
  (e-var [name : Symbol]))
```

# Testing

We care that you test programs well. Programming langauge implementations are
expected to be rock-solid (when’s the last time you ran into an implementation
bug?). You need to uphold this standard.

In addition to the quality and correctness of your code, you will be evaluated
on the quality and correctness of your tests.

## How We Test Tests

It’s probably useful for you to understand how we test your tests.

What’s the job of a test suite (i.e., set of tests)? It’s to find errors in a program. (Examples help you understand the problem before you start writing code, tests help you catch errors in the program as and after you write it.) In short, test suites are like sorting hats, putting programs in a “good” or “bad” bin.

> If you are a mathy person, you might call a test suite a _classifier_.

So, here’s how we will test your test suites. We construct a collection of implementations for the problem. Some are known to be correct (because we built them that way); we call each of these a _wheat_. The others are known to be incorrect (because we intentionally introduce errors); we call each of these a _chaff_. Your test suite’s job is to separate the [wheat from the chaff](https://en.wikipedia.org/wiki/Chaff#Metaphor). That is, we will run each of the wheats and chaffs against your test suite and see what happens:

```
                   | On a wheat… | On a chaff… | 
------------------------------------------------
…all tests passed  |    GREAT!   |  Not great… |
…some tests failed |    Ooops!   |    GREAT!   |
```
All tests passing a wheat, and at least one test failing on a chaff,
is exactly what we are hoping for. If all tests pass on a chaff,
that's not ideal, but you may miss _some_ chaffs, so it may be
okay. But when *any* tests fail on a wheat, that's **definitely** a
problem because it should never happen. It quite likely means you've
misunderstood the problem statement, or perhaps the problem statement
is ambiguous, or something like that. This should get cleared up right
away.

The quality of your test suite is then a measure of whether you passed the wheats and how many chaffs you caught. Of course, we can make the latter arbitrarily hard. For instance, we could define a chaff that always works correctly except when the given list has, say, exactly 1729 elements. We won’t do things like that, both because it’s cruel and because real implementations are very rarely buggy in this way. Instead, we will make “reasonable” mistakes (but not all of them will be easy!).

In short, we will be running _your_ test suite against _our_ implementations. Therefore, it is very important that when you turn in your test suite (see details below), it not be accompanied by your implementation: otherwise, when we try to load ours, DrRacket will complain.

## Guidelines for Testing Your Interpreter

> Please read the [Testing Guidelines](../testing-guidelines.md) for guidelines on how to write tests for the Implementation assignments.

For the purposes of testing, we have defined an `eval` function that calls `parse` and `interp` for you. `eval` consumes a program in the miniPlait language's concrete syntax (`S-Exp`) and returns a miniPlait `Value`:

```
eval :: S-Exp -> Value
```

You should use `eval` in your testing file when writing test cases. You should not directly test `interp` individually in your test file (though you are welcome to and encouraged to individually test these functions in your code file).

In addition to the testing forms documented in the [Testing Guidelines](testing-guidelines-section.html), we provide the following testing form:

- `(test-raises-error? test-name expr)`

    Tests that the given `expr` raises an error. (Example usage can be found in the testing stencil.)

Finally, recall that programs can evaluate to functions. However, you may have chosen a
different representation for closures than we did. Therefore, your tests in your test file should only check that such a program returned a function, and not rely on the specific function returned (because of the differences in representation). For instance, you may write:

```
(test-pred "My predicate test"
           v-fun? (eval `{lam x 5}) #t)
```

> Reminder: In Plait, you can add a `?` to the end of the name of any given type variant to create a function that returns `true` if the expression evaluates to that type variant.

However, you may not write:

```
(test-equal? "Don't write this test"
             (eval `{lam x 5}) (v-fun 'x (e-num 5) (hash (list ))))
```

because our representation of closures may not match your exact representation. (You are, of course, welcome to write test cases of the latter form in your code file.)

## Debugging

You may find it useful to use Plait's [`trace`](https://docs.racket-lang.org/plait/Definitions.html#%28form._%28%28lib._plait%2Fmain..rkt%29._trace%29%29) to help understand the control flow of your interpreter. For instance, if you write

```
(trace interp)
```

then all subsequent calls (including—and especially—recursive calls) to
`interp` will be presented with their arguments and results. Do not
include calls to `trace` in your final submissions.

# Starter Code

This folder contains all necessary stencil code and support code.

The provided folder also contains several files prefixed with `desugar-`. You can ignore
them for this assignment: for reasons explained in [Desugar](../2-desugar/), it's important
you work on the two assignments in the same directory.

We've provided starter code for your implementation at
`interpreter.rkt` and support code at `support.rkt`. You are not
allowed to change the signature of `eval` or `interp`, but you
are welcome to -- and might need to -- add helper functions for your implementation.

We've also provided a stencil for your `eval` test cases at `interpreter-tests.rkt` and testing support code at `test-support.rkt`.
You should check that you can run your `interpreter-tests.rkt` file successfully in DrRacket
before submitting -- if you can't, it means that a definition is missing or you're trying
to test a function that you shouldn't be testing (e.g. a helper function or `interp` directly).

**Do not** modify the contents of `support.rkt` and `test-support.rkt`.

# What We Will Check

Post-deadline, we will review and test the following files in your repository (other files will be ignored):

- `interpreter.rkt`, which should contain your interpreter source.

- `interpreter-tests.rkt`, which should contain the tests for your interpreter.

- `desugar.rkt` and `desugar-tests.rkt` (which you should implement as part of the [next step](../2-desugar/README.md)).