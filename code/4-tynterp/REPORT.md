# Typed interpreter assignment: Report

By introducing a type-checker, you've eliminated the need for certain runtime checks
and error handling in your `interp` function. We'd like you to reflect on this modification
in a short write-up.

Please answer the following questions with a paragraph each:

1. Which runtime errors are now caught by the initial type-check? Which runtime errors
must still be handled by `interp`?

Every error was handled over to the type-checker except for two run-time error which could not
have been delegated to the type-checker.
That is, a run-time error for trying to access an empty list. This error can be raised
by the functions `first` and `rest`. This is because the type system cannot distinguish
between empty and non empty lists, they both have the same type after all.

2. How has the addition of type-checking changed the semantics of our
overall language? Write three programs that run just fine on your
interpreter from Phase 1, but are no longer valid because they fail
the type checker in Phase 3.

The biggest semantic change is that lists are enforced to be homogeneous.
Whereas before, it would be possible to link together a list with different
kind of values such as numbers, strings , ... Etc.

```racket
{link 0 {link "nice" {empty : Str}}}
```

Another change to the language is that sentences with an if-statement
need to return the same kind of values. This means that if-statements
with different kinds of values for their branches are considered invalid
programs.

```racket
{if true "nice" 5}
```

Lastly, another change is that the type annotations need to correspond
with the their values. The following is not a valid statement in phase 3
due to a mismatch in the types between the function argument and
the actual argument.

```racket
{{lam {x : Num} {++ x "1"}} "5"}
```

3. How does adding type-checking affect how long it takes to interpret
a program (ignore the time to type-check)? What kinds of programs
might take less ``wall clock'' running time, what kinds might stay the
same, and what kinds might take more?

Firstly, if the interpreter would have a lot of conditionals due to safety-checks
(ex. `+` can only be used with numbers, `++` can only be used with strings), the
interpreter would run faster with a type-checker. These checks can be ignored if
the interpreter ran with the type-checker. The type-checker already made sure that
these condition would be satisfied. This results in the interpreter have less
conditionals, which would make it faster.

Secondly, if the interpreter had no error-checking conditionals, it would have
been as fast as an equivalent interpreter with a type-checker.
Because esssentially, the interpreter code stayed the same.

Lastly, programs with a lot of run-time errors and conditionals with
different types of branches, would make adding the type-checker on top,
make it run a bit slower. You'll have to add conditionals or ammend the code
in order to adhere to the type-checker's rules of having lists with same type
and having if-branches of same type. This could result in a slower interpreter
due to the fact that you would have more code to interpret because of the changes.

Lastly, If the interpreter had many runtime errors and conditionals involving branches
of different types, it may have a slower performance when a type-checker is added.
This is because adhering to the type-checker's rules, such as ensuring lists contain
elements of the same type or making all branches of conditionals return the same type,
may require modifying or adding extra code. These changes increase the amount of code
the interpreter needs to process, which potententially slows it down.
