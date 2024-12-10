# Testing Guidelines

In addition to the quality and correctness of your code, you will be evaluated
on the quality and correctness of your tests. We grade your tests by running them
against correct and incorrect solutions
(called [wheat and chaff](https://dictionary.cambridge.org/dictionary/english/separate-the-wheat-from-the-chaff) respectively)
that we have written to see whether your tests can tell the difference.

In every assignment where we collect test cases, we will provide two additional files:

1. A `test-support.rkt` file. The `test-support.rkt` file provides specific testing forms
   that you should use when writing tests for the wheats and chaffs. You should not use any
   external testing library other than those specifically provided; otherwise, we will not be
   able to grade your test suite. Please make sure to use the `test-support.rkt` file
   specifically provided with each assignment—some assignments will have assignment-specific
   testing forms to help you when testing.

2. A starter file in which you should write your test suite. This test suite will contain a
   `(define/provide-test-suite test-suite-name ...)` statement, where `test-suite-name` is some
   identifier. You should make sure to write all of your `test` expressions within this statement;
   otherwise, we will not be able to grade your test suite. The testing stencils provide examples
   of how to do this.

While you should never include implementation-specific test cases within your _testing_ file,
you are welcome to (and encouraged to) write implementation-specific test cases within your _implementation_ file.
For example, you may find it helpful to write test cases against your helper functions. However, your implementation
file does not have access to the forms defined in `test-support.rkt`, so you'll need to use either Racket's or
Plait's built-in testing utilities.

## Provided Library

You will always have access to the following forms:

- `(test-equal? name actual expected)`

  `(test-not-equal? name actual expected)`

  Tests that `actual` and `expected` evaluate to the same value (in the case of `test-not-equal?`, different values).

- `(test-true name expr)`

  `(test-false name expr)`

  Tests that `expr` evaluates to `#t` (in the case of `test-false`, `#f`).

- `(test-pred name pred expr)`

  Tests that `expr` returns a value that satisfies the given `pred` predicate.

- `(test-raises-error? name expr)`

  Tests if the given `expr` raises an error.

Some assignments will have specific testing forms; see the assignment specs for more information.

## Error-Handling

When we run your tests, they can result in an error (either due to an intentionally raised error or a bug in a chaff). It is important that invocations of your functions in your tests are caught by a testing statement from our provided testing library, each of which will handle the error automatically. Without a testing statement to handle an error, the test running could terminate due to the error, and you will receive no credit.

Thus, you should write this:

```
(test-equal? "Works with Num primitive"
             (eval `{+ 2 2}) (v-num 4))
```

However, don't write this:

```
(define result (eval `{+ 2 2}))  ; this is not caught by `test-equal?`!
(test-equal? result (v-num 4))
```

That said, if you need to define intermediary variables in a test case, you can use a `begin` or `let` statement:

```
(test-equal? "Multi-statement test case"
             (let ([result (eval `{+ 2 2})])
               result) (v-num 4))
```
