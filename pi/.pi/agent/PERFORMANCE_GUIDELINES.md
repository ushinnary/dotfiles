# Performance Guidelines

> **Scope.** Read and apply this file whenever performance matters: a hot path, a
> latency- or throughput-sensitive endpoint, a tight loop, a large dataset, a
> reported slowdown, or any task where "make it fast" is part of the goal.
> Language- and framework-agnostic. If a rule conflicts with an explicit user
> instruction, the user wins — but say which rule you are setting aside and why.
>
> The cardinal sin of performance work is optimizing by guess. Fast code is a
> product of *measurement and algorithms*, not cleverness sprinkled hopefully.
> Pairs with `CONCURRENCY_GUIDELINES.md` (parallelism) and `BACKEND_GUIDELINES.md`
> (data access).

## Prime directives

1. **Measure first; never optimize by guess.** No performance change without a
   baseline number and, for anything non-obvious, a profile showing where time
   actually goes. Intuition about hotspots is wrong more often than right.
2. **Optimize against a budget, then stop.** Define the target (a p99 latency, a
   throughput, a memory ceiling). Optimization without a target is unbounded and
   wastes effort; once you meet the budget, stop.
3. **Algorithm beats micro-optimization.** The right data structure or one fewer
   pass over the data dwarfs any constant-factor trick. Fix the Big-O before the
   bytes.
4. **The fastest work is the work you don't do.** Cache, memoize, batch, lazy-load,
   short-circuit, and avoid recomputation before you try to speed up the work
   itself.
5. **Latency is a distribution, not a number.** Optimize the tail (p95/p99), not
   just the mean — the tail is what users feel and what cascades into timeouts.
6. **Correctness first, then fast.** An optimization that changes behavior is a bug.
   Every perf change keeps the same tests green (`AGENTS.md` non-negotiable 8).

When these point in different directions, prefer meeting the stated budget with the
simplest change that a reviewer can verify is still correct.

---

## 1. Measure before you touch anything

```
// The performance workflow — no step is optional for non-trivial work:
// 1. Define the metric + target     (e.g. p99 < 200ms; or throughput > 5k rps)
// 2. Measure the baseline           (reproducible benchmark / load test)
// 3. Profile to find the dominant cost (CPU, allocations, I/O wait, lock contention)
// 4. Change the ONE biggest cost
// 5. Re-measure against the baseline — prove the win with numbers
// 6. Stop when the budget is met
```

- **A performance claim needs before/after numbers** from this session, the same way
  a behavior change needs a test. "This is faster" without a measurement is `NOT
  VERIFIED` (`AGENTS.md` non-negotiable 4).
- **Profile, don't guess the hotspot.** Use a profiler/flame graph to find where
  time and allocations actually go. Optimizing a path that isn't hot is wasted work
  that adds complexity for nothing.
- **Benchmark realistically:** representative data sizes and shapes, warm vs cold
  state, production-like conditions. A benchmark over 10 rows tells you nothing
  about 10 million.
- **Amdahl's law:** speeding up something that's 5% of runtime caps your gain at 5%.
  Spend effort on the dominant cost.

---

## 2. Algorithmic complexity is the first lever

- **Know the Big-O of every hot path** in time *and* space; state it when it's
  non-obvious. Reject accidental quadratics (a loop doing a linear scan inside
  another loop) over unbounded input.
- **Pick the data structure for the access pattern:** hash map/set for membership
  and dedup (O(1)) instead of scanning a list (O(n)); sorted structure/heap for
  ordered access; the right index for the query.
- **Hoist invariant work out of loops**; compute once, reuse. Don't recompute,
  re-fetch, re-allocate, or re-compile (regexes!) inside a loop.
- **Process in one pass** where possible instead of repeatedly traversing the same
  collection.
- **Bound the input you operate on:** paginate, limit, sample, or stream. Algorithms
  that are fine on bounded input become outages on unbounded input.

---

## 3. I/O dominates — treat it as the prime suspect

For most backends, the bottleneck is I/O (DB, network, disk), not CPU.

- **Kill N+1 access.** Batch and join; never issue a query/RPC inside a loop over
  results. This is the most common real-world performance bug
  (`BACKEND_GUIDELINES.md` §4) — look here first.
- **Batch and pipeline** remote calls; coalesce many small requests into one.
- **Parallelize independent I/O** (`Promise.all`/`gather`/`errgroup`) instead of
  serial awaits — with a bounded fan-out (`CONCURRENCY_GUIDELINES.md` §6).
- **Stream, don't buffer.** Process large payloads/files/result sets as a stream;
  never load an unbounded dataset fully into memory.
- **Pool expensive resources:** connections, clients, threads. Creating a DB/TLS
  connection per request is a dominant, invisible cost.
- **Move work off the request path:** anything slow, retryable, or bursty goes to a
  background worker/queue so user-facing latency reflects only the user's request
  (`BACKEND_GUIDELINES.md` §5).

---

## 4. Do less work: cache, batch, defer

- **Cache hot, staleness-tolerant reads** — but always with a TTL and an explicit
  invalidation story; a cache without an invalidation plan is a correctness bug in
  waiting (`BACKEND_GUIDELINES.md` §5).
- **Memoize pure expensive computations** keyed by their inputs.
- **Lazy-load and short-circuit:** don't compute or fetch what a given request
  doesn't need; return early on the cheap rejection path.
- **Debounce/throttle/coalesce** repeated triggers (rebuilds, refetches,
  recomputations) so bursts collapse into one unit of work.
- **Precompute and denormalize deliberately** when reads vastly outnumber writes —
  paying at write time to make reads cheap. Note the trade-off when you do.

---

## 5. Memory and allocation

- **Allocation is a cost** — in managed languages, allocation rate drives
  GC pressure and pause times; in unmanaged ones, it's raw overhead and
  fragmentation.
- **Avoid needless copies and intermediate collections.** Chained
  map/filter/collect over large data allocates a throwaway collection per step;
  prefer a single pass, an iterator/generator, or a lazy sequence.
- **Reuse buffers** on genuinely hot paths (object/buffer pools) — but only where a
  profile shows allocation is the bottleneck; pooling adds complexity and its own
  bugs.
- **Right-size eagerly-known collections** (pre-size maps/slices/lists to avoid
  repeated resize-and-copy).
- **Watch for leaks:** unbounded caches, growing collections, unremoved listeners,
  retained references. A "slow memory creep" is a leak until proven otherwise.
- **Data layout matters** for tight numeric loops: contiguous, cache-friendly layout
  beats pointer-chasing — but this is a last-mile concern, not a first move.

---

## 6. Validate the win and guard against regression

- **Re-measure with the same benchmark** and report before/after. If the number
  didn't move, revert the change — complexity without a measured gain is a net loss.
- **Keep the benchmark as an artifact** so the result is reproducible and the
  improvement is defended against future regression.
- **Add a guardrail for the hot path** where the project supports it: a benchmark in
  CI, a performance budget/assertion, a query-count test that fails if N+1 returns.
- **Document the trade-off.** Every optimization trades something (readability,
  memory, staleness, complexity). State what you traded in the report so the next
  reader understands why the code looks the way it does (`AGENTS.md` §6).

---

## Anti-patterns to flag or refuse on sight

- Optimizing without a baseline measurement or a profile ("this should be faster").
- Micro-optimizing a path that profiling shows is cold, while the real hotspot is
  untouched.
- An accidental quadratic: a linear scan / query / lookup nested inside a loop over
  unbounded input.
- N+1 queries or RPCs; remote calls issued one-per-item instead of batched.
- Loading an unbounded dataset fully into memory instead of streaming/paginating.
- A cache with no TTL and no invalidation story.
- Creating an expensive resource (DB/TLS connection, client) per request instead of
  pooling.
- Premature memory pooling / bit-twiddling / data-layout tricks before any
  measurement.
- Sacrificing correctness or readability for an unmeasured, unbudgeted "speedup".
- Claiming a speedup with no before/after numbers.

---

## Definition of done — run this checklist before finishing performance work

1. Is there a stated metric and budget, and a baseline measured this session? (§1)
2. Was the dominant cost found by profiling, not guessed — and is that what you
   changed? (§1)
3. Is the algorithm/data structure right (no accidental quadratic, no N+1, bounded
   input)? (§2–§3)
4. Is I/O batched, parallelized, streamed, and off the request path where it
   should be? (§3)
5. Is repeated work avoided via cache/memoize/lazy/debounce — each cache with a TTL
   and invalidation plan? (§4)
6. Is allocation/memory growth bounded, with no leak and no needless copies on the
   hot path? (§5)
7. Is the win proven with before/after numbers, guarded against regression, and the
   trade-off documented? (§6)
8. Do all existing tests still pass — the optimization changed speed, not behavior?
   (`AGENTS.md` non-negotiable 8)

## When NOT to apply this

Most code is not hot and does not need this. Premature optimization adds complexity,
hides intent, and creates bugs for a speedup nobody can measure. For cold paths,
setup code, and anything off the critical path, write the simplest correct code and
move on. Reach for this guide when there is a real, measured (or confidently
predicted) performance need — and let the profiler, not a hunch, direct the effort.
