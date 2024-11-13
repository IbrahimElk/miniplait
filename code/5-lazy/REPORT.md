# Lazy evaluation assignment: Critical questions

By modifying the interpreter to use lazy evaluation, you've changed the dynamic semantics of the language.
We'd like you to reflect on this modification in a short write-up.

Please answer the following questions with a paragraph each:

1. What would the `{{take 3} {nats-from 0}}` code example evaluate to in your eager (non-lazy) interpreter from step 4?

YOUR ANSWER HERE

2. In call-by-need or lazy languages like Haskell, the language provides a "strictly" or "forcing" operator (i.e. Haskell's `seq`) as a way for programmers to specify when they want to escape laziness and enforce eager evaluation.
What steps are required to include `seq` in this lazy language, and explain using two different examples why such an operator might be useful.

YOUR ANSWER HERE

3. Besides lists, one could imagine adding a heterogenous product constructor `pair` of the product type `A * B`.
How does evaluating `pair`s resemble or differ from the homogenous lazy lists that you implemented?

YOUR ANSWER HERE

4. Your lazy version of miniPlait does not include any features that could introduce any side-effects (like mutable variables/assignment). Explain briefly what would be the potential issue with side-effects in a lazy language.

YOUR ANSWER HERE


