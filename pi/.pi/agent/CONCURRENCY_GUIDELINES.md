# Concurrency Guidelines

> **Scope.** Read and apply this file whenever code runs concurrently or in
> parallel: threads, async/await, goroutines, coroutines, event loops, workers,
> shared caches, or any state touched by more than one request, task, or process at
> once. Language- and framework-agnostic; framework-specific mechanisms are noted
> inline. If a rule conflicts with an explicit user instruction, the user wins — but
> say which rule you are setting aside and why.
>
> Concurrency bugs are the most expensive class of defect: they pass every test,
> appear only under load, and cannot be reproduced on demand. The only winning move
> is to make them *structurally impossible*, not to debug them after the fact.

## Prime directives

1. **Don't share mutable state.** The bug you can't have is the one in state that
   can't be concurrently mutated. Prefer immutability, copies, and message-passing
   over shared memory with locks.
2. **If you must share, make access atomic.** Every read-modify-write on shared
   state is a race unless it is guarded (lock, atomic, transaction) as a single
   indivisible step.
3. **Confine state to one owner.** Give mutable state a single owner (one task, one
   actor, one goroutine, one connection) and communicate by passing messages, not
   by reaching into each other's memory.
4. **Assume everything interleaves.** Between any two operations, any other code can
   run. If a sequence must be atomic, say so explicitly with a primitive.
5. **Idempotent under retry and redelivery.** At-least-once delivery and client
   retries mean the same operation arrives twice. Design so the second time is a
   no-op (`PERFORMANCE_GUIDELINES.md` and `BACKEND_GUIDELINES.md` agree).
6. **Bound everything.** Unbounded queues, goroutine/thread spawning, and buffers
   turn a traffic spike into an out-of-memory crash. Cap concurrency explicitly.

When these point in different directions, prefer the design that removes shared
mutable state entirely — it is the only one that scales to reviewers and to load.

---

## 1. Eliminate shared mutable state first

Before reaching for a lock, ask whether the sharing is necessary at all.

- **Immutability by default.** Immutable values are free to share across any number
  of workers — no lock, no race, ever. Make value objects immutable; return new
  values instead of mutating in place.
- **Copy at the boundary.** Hand each worker its own copy of the data it needs
  rather than a shared reference, when the data is small enough.
- **Confinement.** Keep mutable state local to one task and expose it only through a
  channel/queue/mailbox. _Go:_ "share memory by communicating." _Erlang/Elixir/
  Akka:_ actors. _JS/Node:_ a single event-loop owner. _Rust:_ ownership makes this
  the default the compiler enforces.
- **Thread-local / request-scoped** state for anything that doesn't actually need to
  be shared (loggers, buffers, RNG instances).

---

## 2. When you must share, guard correctly

```
// ANTI-PATTERN: check-then-act race. Two callers both see balance >= amount.
if (account.balance >= amount) {        // T1 and T2 both pass here
  account.balance -= amount;            // both debit — balance goes negative
}

// PREFER: make the decision-and-mutation a single atomic step
//  - DB: UPDATE accounts SET balance = balance - :amt WHERE id=:id AND balance >= :amt
//        (then check rows-affected), or SELECT ... FOR UPDATE inside a transaction
//  - in-memory: hold one lock across both the check and the write
//  - or: an atomic compare-and-swap / fetch-and-add primitive
```

- **The critical section covers the whole invariant**, not just the write. A lock
  around only the mutation but not the check still races.
- **Hold locks briefly**; never perform I/O (network, disk, a third-party call)
  while holding a lock — it serializes the whole system on your slowest dependency.
- **Prefer higher-level primitives** to raw locks: atomics, concurrent/immutable
  collections, transactional memory, or the datastore's own atomic ops and
  optimistic-locking (version columns). Raw mutexes are the assembly language of
  concurrency.
- **Don't guard with `volatile`/visibility keywords alone** — visibility is not
  atomicity. A flag being visible doesn't make `count++` safe.

---

## 3. Prevent deadlock, livelock, and starvation

- **Global lock ordering.** If a path acquires more than one lock, every path
  acquires them in the same documented order. Inconsistent ordering is the classic
  deadlock.
- **Acquire one lock at a time** where possible; the safest number of nested locks
  is zero, the next safest is one.
- **Always use timeouts** on lock acquisition and blocking waits so a deadlock
  degrades to a recoverable error instead of a permanent hang.
- **No I/O or callback under a lock** — calling back into unknown code while holding
  a lock invites both deadlock and reentrancy bugs.
- **Fairness:** ensure no worker can be starved indefinitely; prefer fair queues for
  contended shared resources.

---

## 4. Async / await and event loops

- **Never block the event loop / async runtime.** A synchronous CPU-bound or
  blocking-I/O call inside an async context stalls *every* concurrent task. Offload
  CPU work to a worker/thread pool; use the async variant of every I/O call.
- **Propagate cancellation.** Thread the cancellation token / `AbortSignal` /
  `context` through every await so a cancelled or timed-out request actually stops
  the work it spawned (`BACKEND_GUIDELINES.md` §5).
- **Await deliberately.** Fire-and-forget tasks swallow errors and outlive their
  request — track them, await them, or hand them to a supervised runner. An
  unawaited failure is a silently swallowed error (`AGENTS.md` non-negotiable 6).
- **Parallelize independent awaits** (`Promise.all`/`gather`/`errgroup`) instead of
  awaiting sequentially — but cap the fan-out (§6).
- **Beware shared state across an await point**: state can change while you were
  suspended. Re-validate assumptions after awaiting.

---

## 5. Concurrency at the data and service layer

- **Atomic at the source of truth.** Push concurrency control down to the datastore
  (atomic updates, `FOR UPDATE`, optimistic version columns, unique constraints) —
  it is the one place all instances agree on. Application-level locks don't work
  across horizontally-scaled instances.
- **Idempotency keys** for state-changing endpoints and queue consumers so retries
  and at-least-once redelivery don't double-apply (`BACKEND_GUIDELINES.md` §5).
- **Distributed locks are a smell**; prefer designing the operation to be
  idempotent or to use a conditional/atomic DB write. If you must use one, it needs
  a TTL and fencing token.
- **Exactly-once is a myth over the network** — design for at-least-once delivery
  plus idempotent processing instead of chasing it.

---

## 6. Bound and supervise concurrency

- **Cap concurrency explicitly:** worker-pool size, max in-flight requests, semaphore
  permits. Unbounded `spawn`/`go`/`new Thread` per request is a memory bomb under
  load.
- **Bound every queue and buffer**; an unbounded channel just relocates the OOM.
  Apply backpressure when full — block, shed, or reject, but decide consciously.
- **Supervise long-lived workers:** restart on crash, surface the error, don't let a
  dead worker silently stop processing.
- **Clean shutdown:** on termination, stop intake, drain or checkpoint in-flight
  work, cancel outstanding tasks, then exit (`BACKEND_GUIDELINES.md` §6).

---

## 7. Testing concurrency

Concurrency bugs hide from example-based tests. Attack them deliberately:

- **Stress / soak tests:** run the operation from many workers simultaneously,
  thousands of iterations, and assert the invariant held (no lost update, no
  negative balance, count is exact). A single-threaded test proves nothing about
  thread-safety.
- **Use the tooling:** race detectors and sanitizers (`go test -race`, TSan,
  `-fsanitize=thread`), thread-safety linters, and deterministic schedulers where
  the platform offers them. Run them in CI.
- **Property/invariant tests:** assert "balance never goes negative regardless of
  operation interleaving" rather than checking one hand-picked sequence
  (`AGENTS.md` §4).
- **Make it deterministic where you can:** inject the clock and scheduler so the
  race-prone path can be driven reproducibly in a test (`AGENTS.md` §4).
- **Regression-test every concurrency bug** with a test that reliably reproduced it
  before the fix (`skills/fix-bug`) — even if that means looping it N times.

---

## Anti-patterns to flag or refuse on sight

- Check-then-act on shared state without an atomic guard (race / TOCTOU).
- A lock around the write but not the read it depends on.
- I/O, a network call, or a callback performed while holding a lock.
- Multiple locks acquired in inconsistent order across code paths (deadlock).
- Blocking or CPU-bound work on an async runtime / event loop.
- Fire-and-forget async tasks whose errors are never observed.
- Unbounded `spawn`/`go`/thread-per-request, or an unbounded queue/buffer.
- Application-level in-memory locks used to coordinate across horizontally-scaled
  instances (they don't).
- `volatile`/visibility keyword used as if it provided atomicity.
- Thread-safety asserted with only single-threaded or happy-path tests.

---

## Definition of done — run this checklist before finishing concurrent work

1. Is shared mutable state eliminated where possible (immutability, confinement,
   message-passing)? (§1)
2. Is every read-modify-write on remaining shared state atomic — the full invariant
   guarded, not just the write? (§2)
3. Multiple locks: acquired in one documented global order, with timeouts, no I/O
   held under a lock? (§3)
4. Async: nothing blocks the runtime; cancellation propagates; no unobserved
   fire-and-forget tasks? (§4)
5. Is concurrency control at the datastore the source of truth, with idempotency
   keys for retried/redelivered operations? (§5)
6. Is concurrency bounded — pool sizes, in-flight caps, bounded queues, clean
   shutdown? (§6)
7. Tested under real concurrency (stress + race detector + invariant assertion),
   not just a single-threaded happy path? (§7)

## When NOT to apply this

A strictly single-threaded script, a pure function with no shared state, or a tool
with no concurrency needs none of this. Don't add locks, pools, or atomics to code
that never runs concurrently — unnecessary synchronization is its own bug source and
performance drag. Apply this the moment a second thread, request, or consumer can
touch the same state, and not before.
