# SessionML

Experimental functional language implemented in OCaml, exploring what should
happen when a program stops using a communcation channel before its protocol
is finished.

Session types help specify the order as well as types of messages that
are exchanged over a channel. They help catch protocol mistakes, however,
they are not sufficient in and of themselves to explain what a waiting
process should do if the channel is abandoned. Here, we explore a potential
resolution: *automatic cancellation of unfinished channel endpoints whenever
they leave lexical scope*.

We compare two modes of the same language:

1. **Strict linear**: endpoint MUST be used according to protocol, or transferred to another owner. Unfinished endpoints cannot just be dropped.
2. **Affine**: endpoint still cannot be copied, however, may be left unused. When owned endpoint goes out of scope, compiler will insert an explicit cancellation opereation.

Our ultimate goal here is to make the abandonment of channels observable,
without having to rely on things like garbage collection, or destructors.

Written for Purdue's Fall 2026 CS456 (Programming Languages) class taught
by Prof. Suresh Jaganathan.

## Example

Let's say a sender needs to adhere to the below protocol:

```text
!Int.!Int.!Bool.End
```

Correspondingly the receiver follows the dual protocol `?Int.?Int.?Bool.End`.

Now, let's say we have this code:

```ocaml
let sender c =
  let c1 = send(c, 10) in
  let c2 = send(c1, 20) in
  () (* c2 still owned here *)
```

strict linear mode would reject this function since we are leaving the session
unfinished. Affine mode on the other hand would accept it, and insert
`cancel(c2)` when the function returns. This means that the receiver is able
to read `10`, `20` in that order, and on the next receive will see `Cancelled`
instead of waiting forever for a `Bool`.


## Planned language & runtime

Core language will have the following:
- ordinary values
- let bindings
- conditionals
- first order functions
- communication operations
  1. `fork`
  2. `send`
  3. `receive`
  4. `close`
  5. `cancel`

## Current status

Still in development.

Implementation milestones:

1. define session types, duality, core syntax
2. implementation of strict linear checking, endpoint ownership rules
3. affine checking, scope exit cancellation elaboration
4. implementation of asychronous FIFO queues, deterministic 2 process scheduler
5. testing ownership, queued messages, cancellation, closing behaviour
6. comparing the 2 mode, investigating a stricy soundness argument.

Intended soundness properties:
- preservation of well typed configs
- cancellation aware progress

## Building & Testing

Using Nix to provide OCaml, Dune, QCheck, etc. opam NOT required.

``bash
nix develop
dune build
dune runtest
```

if `direnv` installed, `direnv allow` can be run once in the project directory,
and from then on `.envrc` loads the Nix development env automatically whenever
this directory is entered.

## Background

Relevant work:
- Mostrous and Vasconcelos, [*Affine Sessions*](https://doi.org/10.23638/LMCS-14(4:14)2018) (2018).
- Fowler et al., [*Exceptional Asynchronous Session Types: Session Types Without Tiers*](https://doi.org/10.1145/3290341) (2019).
- Kokke, [*Rusty Variation: Deadlock-Free Sessions with Failure in Rust*](https://doi.org/10.4204/EPTCS.304.4) (2019).
- Wadler, [*Propositions as Sessions*](https://doi.org/10.1145/2364527.2364568) (2012).
