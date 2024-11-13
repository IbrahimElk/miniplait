# Introduction

> Note: this is an **optional "stretch" task**. If you completed all the previous 4 assignments and you want to obtain the bonus point to achieve a maximum grade, then you should also complete this task.

For this assignment, you will implement a modified version of miniPlait that uses _lazy_ evaluation.

Lazy programming is an idea from the 1970s and 1980s that is finally
making it into mainstream programming, e.g., through Java 8's streams.

The concept of Laziness is explained in the PLAI v3 textbook as a subsection in the chapter on "Non-standard models".

To understand how to implement laziness in an interpreter, see
[chapter 17.1 of PLAI v2](http://cs.brown.edu/courses/cs173/2012/book/Alternate_Application_Semantics.html#%28part._.Lazy_.Application%29).

## Optional Reading

To see examples, and understand the beautiful
programming patterns that laziness enables, read this classic paper by
John Hughes, entitled
[Why Functional Programming Matters](http://www.cse.chalmers.se/~rjmh/Papers/whyfp.html).

# Getting started

This **optional** task requires the solution for the language that you implemented in step 4 (Typed miniPlait with Lists).
Once completed, **copy your solution for task 4 into this directory** and modify the code to implement the features below.
In particular, use your solution to **phase 3**, where you combined type checking and interpretation.
This assignment will modify the type checker (`type-of`) and interpreter (`interp`). It might also modify desugar, depending on your implementation.

# Features to implement

## Lazy Evaluation

Lazy evaluation means that arguments to functions should not be evaluated if
they are not used in the body. As a result, function calls and the `link` constructor for lists must be **lazy**: that is, a function must
not evaluate its argument if it is not used, and a `(link x y)` must not evaluate its `x` or `y` if they are not used. `let`'s value should also be lazy.

### Strictness Points

On the other hand, certain parts of the language _should_ force their arguments
to be evaluated. These _strictness points_ should force an expression to have a
value. Specifically:

- The operators `+`, `++`, `first`, `rest`, `num=`, and `str=` should force all of
   their arguments to be evaluated.

- `if` should force its condition to be evaluated as well as the target
   branch of the conditional (that is, if the condition evaluates to `true`,
   then the `consq` branch should be forced, and if the condition evaluates to
   `false`, then the `altern` branch should be forced).

- `first` should force the _first_ element of the list to be
   evaluated.  

- `rest` should force the head of the list: after all, if the list is empty there is no rest! But note that `rest` does not evaluate any of the rest of the elements of the list (i.e. the elements past the head of the list).

- Function application should force the function expression to be evaluated to a function value.

- The "top-level" `eval` should force its result to be evaluated (so it can show the end-user an answer, rather than a suspended computation).

All forced evaluations should be shallow; that is, you should not recursively
force values inside of a concrete value. In particular, you should not
recursively force values inside of `List`s.

There are no wheats and chaffs for this assignment, and you do not
need to submit a separate test suite. You can assume we will not test
your implementation on any error cases.

## Typing recursion

To test your lazy interpreter, it is useful to write recursive functions over lists. For instance, you can inductively define the infinite list of natural numbers:

```
{let {nats-from
       {lam {n : Num}
         {link n {nats-from {+ 1 n}}}}
       : (Num -> (List Num))}
  {nats-from 0}}
```

There's just one problem: the name bound by `let` (here: `nats-from`) is not yet bound in the argument expression (here: the `lam` expression)!

To fix this, we will need a new construct called `rec` (for recursion). See PLAI v3 "Typing Recursion" (p. 129) to understand how this works.

Concretely you will need to add support for the following syntax:

```
{rec {NAME EXP : TYPE} BODY}
```

Which parses to the following new type variant:

```
(define-type Expr
  ...
  (e-rec [id : Symbol]
         [value : Expr]
         [value-type : Type]
         [body : Expr]))
```

The above example can then be rewritten using `rec`.

> To make these changes, you will need to edit the `support.rkt` file which you copied over from task 4.

To test your code, you can additionally define a recursive function `take` which takes a number `n` and a stream (infinite list) `s` and returns a new stream (finite list) with only the first `n` elements of `s`:

```
{rec {take {lam {n : Num}
             {lam {s : (List Num)}
              {if {num= n 0}
                  {empty : Num}
                  {link {first s}
                        {{take {+ n -1}} {rest s}}}}}}
           : (Num -> ((List Num) -> (List Num)))}
  { {take 3} {nats-from 0} }}
```

In the above example, we use `take` to extract the first 3 numbers from the infinite stream of natural numbers generated by `{nats-from 0}`. This should return the list `{link 0 {link 1 {link 2 {empty : Num}}}}`.

# Analysis

This assignment has fundamentally changed the dynamic semantics (i.e. the execution) of programs in miniPlait. We'd like you to reflect on these changes by answering some questions. See [REPORT.md](./REPORT.md).

# What To Hand In

You will submit the following files for this assignment:

* `tynterp.rkt` for your implementation
*  and add your tests in `tynterp-tests.rkt`.
*  you also updated your parser and language definition in `support.rkt`.

For the mandatory reflection questions, you also submit `REPORT.md`.

You can update your submissions as many times as you want before the deadline.
