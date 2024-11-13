# CPL Assignment 2024-2025

## Implementing "miniaturized dinnerware" (miniPlait)

In this project, you will be using plait as a metalanguage to implement a small functional programming language called miniPlait.
In essence, miniPlait is a stripped-down version of plait: 
* it is lexically scoped,
* uses eager, call-by-value evaluation
* featuring variables, 
* basic operators, 
* first-class functions, 
* and static types.

In fact, right now it has none of these features -- implementing them is precisely the objective of this assignment.

The project is subdivided into **four mandatory tasks** and **one optional "stretch" task**.
Implementing the four mandatory tasks correctly (including testing them extensively) will net you a comfortable passing grade.
For high-achievers, implementing all five components correctly can net you the maximum score of 5/5.

> ⚠️ N.B. \
> As a general guideline, we budget the amount of time you will spend on this assignment to be 35-45 hours (1.5 ECTS).
> If you find that you are stuck and have spent more than 5 hours implementing a feature and have made no progress, contact me at `denis.carnier@kuleuven.be` and we can work through the problem together.

For grading purposes, it is **extremely important** -- foremost, principal, central, _paramount_ even -- that you follow the [testing guidelines](code/testing-guidelines.md) to the letter. Additionally, careful read and apply the testing instructions found in each of the tasks.

## Getting started

Read the `README`s in each of the task directories under `code/`. These files should be self-explanatory if you've followed the plait exercises earlier this semester.

## Submissions

The absolute final deadline is 23:59 CET on Monday, December 23, 2024. Here are two other formats that should hopefully resolve any ambiguousness as to _when_ that is:
* ISO 8601: `2024-12-23T22:59:59+0000`
* UNIX time: `1734994799`

### How to submit

At the above mentioned timestamp, your GitLab repository will be automatically archived. This essentially freezes it in time: you will no longer be able to push commits or branches or tags or anything that alters the state of the repository.
For grading purposes, only your `main` branch will be inspected.

> ⚠️ N.B. \
> Ensure that at the moment of the deadline, your intended submission is the latest commit on the `main` branch of your repository.

It is not necessary to archive your repository and upload it anywhere else.

It can be useful to work incrementally: create a separate branch from `main` to implement solutions and rebase/merge/... commits back to `main` whenever you finish a particular task.

> ⚠️ N.B. \
> Make sure to **allot adequate time** before the deadline for pushing your solution to `main`. Every year there are students that do not follow this advice and inevitably do not submit a finished solution.

> ⚠️ N.B. \
> Double check that besides code and tests, you have also **answered the mandatory reflection questions** found in `REPORT.md` inside the subdirectory of task 4 and (optionally) task 5. 

## Grading

For grading purposes, it is **extremely important** -- foremost, principal, central, _paramount_ even -- that you follow the [testing guidelines](code/testing-guidelines.md) to the letter. Additionally, careful read and apply the testing instructions found in each of the tasks.

Your solution should not only implement the required feature correctly, but also extensively test for **all edge cases** that can occur.
Note that the interaction of features from later tasks may subtly influence the behaviour of earlier features.

Parts of your submission will be **automatically graded** but subject to manual review.
Ensure that the solution you submit:
* is syntactically valid;
* executes without errors in your local DrRacket environment;
* is extensively documented;
* implements the required features correctly (meaning your solution is both _sound_ and _complete_ with respect to the specified behaviour in the assignment);
* and has extensive unit tests covering as many edge cases as you can think of.

If any of the above is not true, the final (number) grade on your project will reflect this.

## Code of conduct

The expectation is that you make this project **individually**. You should not team up with others to jointly work on the project. It is fair game to discuss the tasks and solution strategies with your fellow classmates of course, but directly sharing solution code in whole or in part is forbidden.

We will check code (and tests!) for plagiarism.

Use of GenAI tools should be clearly attributed in source comments and/or reports, as per university policy.

Good luck with the project!