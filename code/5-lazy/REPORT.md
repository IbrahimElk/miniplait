# Lazy evaluation assignment: Critical questions

By modifying the interpreter to use lazy evaluation, you've changed the dynamic semantics of the language.
We'd like you to reflect on this modification in a short write-up.

Please answer the following questions with a paragraph each:

### 1. What would the `{{take 3} {nats-from 0}}` code example evaluate to in your eager (non-lazy) interpreter from step 4?

If `rec` was implemented in the eager interpreter from step 4, it would basically
loop forever.

Assuming the interpreter evaluates from left to right. It will evaluate `{take 3}` first,
which would result in a lambda function which expects a *list* of numbers. Afterwards,
the interpreter will evaluate the argument. This is in contrast with a lazy interpreter
which would **not** evaluate the argument. It will try to evaluate `{nats-from 0}`,
good luck with that... . `natsfrom 0` will loop forever and never get back to the function `{take 3}`

### 2. In call-by-need or lazy languages like Haskell, the language provides a "strictly" or "forcing" operator (i.e. Haskell's `seq`) as a way for programmers to specify when they want to escape laziness and enforce eager evaluation. What steps are required to include `seq` in this lazy language, and explain using two different examples why such an operator might be useful

The `seq` operator takes in two expressions. It eagerly evaluates the first expression
and returns the result of the evaluated second expression. The following is the steps
needed in order to include `seq` into the miniPLAIT language.

- Add a `seq` case to the parser
- Add a `seq` operator to the AST, i.e. under binary operators.
- Add a `seq` case to the desugarer & interpreter and type-checker

In the interpreter, you would want to strictly evaluate the first expression given by `seq`.
You drop the result of the first expression and start evaluating the second expression.
Once finished, you return the value of the second expression. This is inline with how `seq` does it in Haskell.

```haskell
ghci> :t seq
seq :: a -> b -> b
```

To sum up, you want to fully enforce eager evaluation, you want to completely evaluate something before moving on to the next.
Such an operator `seq` could be implemented as follows:

```racket

;; pseudocode
(define (eval-seq expr1 expr2 env)
(begin
   (strictFull (eval-env expr1 env))
   (eval-env expr2 env)
)

```

On to the uses cases for such an operator.

- First use case:  
You would want to not stack a lot of suspensions before continuing execution.
This could be for performance reasons, and to free some memory.

- Second use case:  
Debugging can become difficult since you don't know exactly when an expression will be
evaluated. It depends on the strictness points and which of those the interpreter will
be using for a particular expression. The operator `seq` essentially adds your own strictness
point in order to enforce the evaluation of an expression in order to debug that expression.

### 3. Besides lists, one could imagine adding a heterogenous product constructor `pair` of the product type `A * B`. How does evaluating `pair`'s resemble or differ from the homogenous lazy lists that you implemented?

For lazy lists, only the head of the list is evaluated whether `first` or `rest` is used, with the tail remaining unevaluated until needed.
In contrast, with pairs if you implement a `fst` and `snd` to access the elements of the pair, only one of the two elements are evaluated
while the other remains unevaluated depending if `fst` or `snd` is used. However, both structures share the core principle of lazy evaluation.
Elements are suspended until their values are required for further computation. This means that, like with lazy lists, the elements of a pair
will not be evaluated immediately but only when one of the elements is accessed.

### 4. Your lazy version of miniPlait does not include any features that could introduce any side-effects (like mutable variables/assignment). Explain briefly what would be the potential issue with side-effects in a lazy language

A function call with no side-effects makes it possible to evaluate the function at any time.
Since no side-effect are present, whether you call the function expression now or later,
should have no effects on the result. That is what functional programming is all about.
The result of a function only depends on the input and not on any state, which in turn makes
lazy evaluation possible.

By introducing mutability, you may be able to introduce state and change it, which would result in
the function not returning the same value when the input is the same. So, lazy evaluation has to consider
when the function can be evaluated such that the return value does not change, i.e. when is there no state change?
And in that time frame, it can choose when to evaluate it.
