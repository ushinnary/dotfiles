# Backend Engineering Guidelines

> **Scope.** Read and apply this file whenever you write, refactor, or review
> backend code — APIs, services, workers, jobs, data access, or domain logic — in
> any language (Go, Java/Kotlin, C#, Python, TypeScript/Node, Rust, Ruby, PHP, …)
> and any framework. It is language- and framework-agnostic. Where a principle maps
> to a framework-specific mechanism, that mapping is noted inline. If a rule
> conflicts with an explicit user instruction, the user wins — but say which rule
> you are setting aside and why.
>
> This complements the global rules in [`AGENTS.md`](AGENTS.md) and the
> [`checklists/security.md`](checklists/security.md) gate; it does not replace them.

## Prime directives

1. **Dependencies point inward.** Domain logic knows nothing about the web
   framework, the database, or the message broker. Outer layers depend on the core,
   never the reverse.
2. **The domain is pure; the edges are dirty.** Keep business rules free of I/O.
   Push HTTP, SQL, files, clocks, and network to the boundary behind interfaces.
3. **Make illegal states unrepresentable.** Encode invariants in types and
   constructors so invalid data cannot be built, not just rejected later.
4. **Validate at the boundary, trust within.** External input is hostile until
   parsed into a domain type at the edge. Inner code receives only valid data.
5. **Design for failure.** Everything remote times out, retries, and fails. Make
   operations idempotent, set deadlines, and fail closed.
6. **Stateless by default.** Put state in the datastore, not the process. Any
   instance can serve any request; this is what lets you scale horizontally.
7. **Measure before optimizing, but never ship the obvious quadratic.** Correct,
   then measured, then fast — yet don't merge an N+1 or an unbounded scan that you
   already know is there.
8. **A feature isn't done until its failure modes are tested.** The tests that
   matter most are the ones covering what would give the end user a bad experience.

When these principles point in different directions, prefer the one that keeps the
system **easy to change, easy to test, and safe under load**.

---

## 1. Layered / clean architecture

Separate by responsibility, with dependencies pointing inward toward the domain:

```
delivery/transport   HTTP/gRPC/CLI/queue handlers — parse input, call use case,
                     map result to response. No business logic here.
   ↓ depends on
application/use-cases Orchestrates a single operation: validates, coordinates
                     domain + ports, manages the transaction boundary.
   ↓ depends on
domain               Entities, value objects, domain services, business rules.
                     Pure. No imports from outer layers, no framework, no I/O.
   ↑ implemented by
infrastructure       DB repositories, HTTP clients, brokers, caches — concrete
                     implementations of interfaces ("ports") the inner layers define.
```

- **Ports and adapters.** The application layer declares interfaces it needs
  (`UserRepository`, `PaymentGateway`, `Clock`). Infrastructure implements them.
  This is what makes the core testable without a database or network.
- **Don't leak framework types inward.** No request/response objects, ORM entities,
  or `context`/`HttpContext` past the delivery layer. Map to domain types at the
  edge.
- **One use case = one operation.** "Register user", "place order". It reads as a
  short script: validate, load, decide, persist, emit. If a use case is hard to
  describe in a sentence, split it.
- **Keep DTOs and domain models distinct.** The shape you expose over the wire is an
  API contract that evolves on a different schedule than your domain model. Map
  between them explicitly; don't serialize domain entities directly.

**Match ceremony to size.** A small service or a single endpoint does not need four
packages and a mapper for every type — see "When NOT to apply this". The point is
the *direction of dependencies*, not the number of folders.

---

## 2. Keep the domain pure and isolated

Business rules that depend on the wall clock, a random source, the database, or the
network are untestable and brittle.

```
// ANTI-PATTERN: domain logic reaches out to I/O and global time
function expireSubscription(userId) {
  const user = db.query("SELECT ... WHERE id = ?", userId);   // I/O in the rule
  if (Date.now() > user.expiresAt) {                          // global clock
    db.update("UPDATE ... SET active = false");               // I/O in the rule
  }
}

// PREFER: pure decision, injected dependencies, I/O at the edge
// domain — pure, trivially testable
function isExpired(subscription, now) {
  return now > subscription.expiresAt;
}
// application — orchestrates I/O around the pure decision
async function expireSubscription(id, repo, clock) {
  const sub = await repo.findById(id);
  if (isExpired(sub, clock.now())) await repo.deactivate(id);
}
```

- Inject `Clock`, `IdGenerator`, `RandomSource` as dependencies; never call the
  global clock/RNG inside a business rule. This makes tests deterministic
  (see `AGENTS.md` §4).
- Side effects (sending email, emitting events) are requested by the domain and
  performed by the infrastructure — return an intent, don't perform the effect in
  the rule.

---

## 3. Validate and model at the boundary

Parse external input into domain types at the edge; inner layers never see raw
strings or untyped maps.

- Validate type, length, range, and format on every external input — request
  bodies, query params, headers, message payloads, env, third-party responses
  (`AGENTS.md` non-negotiable 10).
- **Parse, don't validate-and-pass-along.** Turn input into a typed value object
  (`EmailAddress`, `Money`, `UserId`) once, at the boundary. Downstream code takes
  the type and cannot receive an invalid value.
- Reject unknown fields where it matters; be explicit about optional vs required.
- Return precise, structured errors for bad input (see §6) — never a 500 for what
  is a 400.

---

## 4. Data access and persistence

The datastore is usually the first thing to fall over under load. Treat data access
as a first-class design concern.

- **Repository/gateway behind an interface.** The domain depends on
  `OrderRepository`, not on the ORM or SQL. Swappable, mockable, testable.
- **Kill N+1 queries.** Batch, join, or eager-load deliberately. Never issue a
  query inside a loop over rows. This is the single most common backend performance
  bug — flag it on sight.
- **Index what you filter and join on.** Every query that hits a hot path runs
  against an index, not a full scan. Know your query plan for the critical paths.
- **Always bound result sets.** Paginate or limit every list endpoint and every
  internal query that can grow unbounded. Prefer keyset/cursor pagination over
  large `OFFSET`.
- **Own your transaction boundary.** One use case = one transaction, started in the
  application layer. Keep transactions short; never hold one open across a network
  call to a third party.
- **Concurrency is real.** Use optimistic locking (version columns) or
  appropriate isolation for read-modify-write; don't assume single-threaded access.
- **Migrations are forward-only and backward-compatible.** Deploy expand →
  migrate → contract so the old and new code both run during rollout. Never write a
  migration that breaks the currently-running version.

---

## 5. Designed to scale

Scaling is a design property, not a tuning step you bolt on later.

- **Stateless processes.** No session state, no in-memory caches that must be
  consistent across instances, no "sticky" assumptions. Externalize state to the
  DB, a cache (Redis), or the client (signed token). This lets you add instances
  freely.
- **Cache deliberately, invalidate honestly.** Cache reads that are hot and
  tolerant of small staleness. Always set a TTL; have an explicit invalidation
  story. Never cache without knowing how stale data gets corrected.
- **Offload slow and bursty work to a queue.** Anything slow, retryable, or
  spike-prone (email, image processing, third-party calls, fan-out) runs in a
  background worker, not in the request path. Keep request latency about the user's
  request only.
- **Make handlers idempotent.** Network retries and at-least-once queues mean the
  same request can arrive twice. Use idempotency keys / dedup so a retry doesn't
  double-charge or double-send.
- **Backpressure and limits.** Rate-limit public endpoints, cap request body sizes,
  set connection-pool and concurrency limits. A system without limits fails
  catastrophically instead of degrading.
- **Set timeouts and deadlines on every remote call** and propagate cancellation
  (context/`CancellationToken`/`AbortSignal`). A hung dependency must not pin your
  threads/connections forever.
- **Isolate failures.** Use circuit breakers, bulkheads, and sensible retry with
  jittered backoff for downstream dependencies, so one slow dependency doesn't take
  the whole service down.

---

## 6. Errors, observability, and operability

You cannot scale or debug what you cannot see, and a service that fails opaquely
gives the end user a worse experience than one that fails cleanly.

- **Distinguish error classes.** Client error (4xx — caller's fault, don't retry),
  server error (5xx — your fault), and transient (retryable). Map them to correct
  status codes / result types; don't return 500 for validation failures.
- **Errors carry context, not secrets.** Internal logs say what failed, with which
  inputs (IDs, not PII/secrets), and where. Outward-facing messages are safe and
  actionable, never stack traces, queries, or connection strings (`AGENTS.md` §1).
- **Structured logging.** Log as structured key/value with a correlation/request ID
  threaded through the whole request and into background jobs. No `print` debugging
  left behind.
- **The three signals.** Emit metrics (latency, error rate, throughput, saturation
  — the RED/USE signals), traces across service boundaries, and logs. At minimum,
  every endpoint has latency and error-rate metrics.
- **Health and readiness.** Expose liveness and readiness checks; readiness must
  reflect real dependency health (DB reachable) so orchestration routes traffic
  correctly.
- **Graceful shutdown.** On termination, stop accepting new work, finish or
  checkpoint in-flight work, and release resources. Don't drop requests on deploy.

---

## 7. Configuration, secrets, and dependencies

- **Config from the environment**, not hardcoded; fail fast at startup if required
  config is missing or invalid (validate config like any other boundary input).
- **Secrets only via env or a secret manager** — never in code, logs, or commits
  (`AGENTS.md` non-negotiable 1). Rotate-able by design.
- **Least privilege** for every credential, DB user, and service account
  (`AGENTS.md` §1).
- **Dependencies are attack surface and operational risk.** Prefer the standard
  library, then what's already in the lockfile; pin versions; adding one is an
  architectural decision to call out (`AGENTS.md` §1).

---

## 8. Testing — cover what hurts the user

A new feature ships with tests that fail without it (`AGENTS.md` non-negotiable 8),
and the tests prioritize the failures a real user would actually feel. Coverage
percentage is not the goal; **covering the paths that cause a bad user experience
is.**

Test at the right level — most tests fast and isolated, fewer broad ones:

- **Domain / unit (the bulk).** Pure business rules tested directly: every branch,
  boundary, and invariant. Fast, deterministic, no I/O. This is cheap because §1–§2
  kept the domain pure.
- **Use-case / integration.** The use case wired to real adapters (real DB via
  container/in-memory, fakes for third parties). Verifies transactions, queries,
  and mapping actually work — the seams unit tests can't see.
- **Contract / API.** The transport layer: status codes, validation errors,
  serialization, auth. Lock the API contract so you don't silently break clients.

**Always cover the user-facing failure modes** — these are non-negotiable for a new
feature:

- Invalid, missing, malformed, and boundary input → correct 4xx, clear message
  (not a 500, not a silent wrong result).
- Empty / not-found / unauthorized / forbidden paths.
- Duplicate submissions and retries → idempotency holds (no double effect).
- Concurrent access to the same resource → no lost update or corruption.
- Downstream dependency slow / failing / timing out → graceful degradation, correct
  error, no hang.
- Pagination limits and large result sets → bounded, no unbounded query.

Properties:

- **Deterministic:** no real clock, RNG, network, or shared global state; inject
  them (`AGENTS.md` §4). Order-independent.
- **Through public interfaces,** not private internals — so refactors don't break
  tests.
- **Each test states its scenario in its name:** `rejects_order_when_balance_below_total`.
- **Bug fixes get a regression test** that fails on the pre-fix code
  (`skills/fix-bug`).

---

## Anti-patterns to flag or refuse on sight

- Business logic inside a controller/handler, or SQL/ORM calls inside the domain.
- Framework, request, or ORM types leaking into the domain layer.
- Domain rules calling the global clock / RNG / `now()` directly (untestable).
- N+1 queries; a query inside a loop; a list endpoint with no pagination/limit.
- Stuffing request-scoped or session state into process memory (breaks horizontal
  scaling).
- Slow or third-party work done synchronously in the request path instead of a queue.
- Remote calls with no timeout, no retry policy, or no cancellation propagation.
- Non-idempotent handlers behind an at-least-once queue or retrying client.
- Returning 500 for validation errors; leaking stack traces/queries/PII outward.
- Catching and swallowing errors, `|| true`, ignored error returns
  (`AGENTS.md` non-negotiable 6).
- A migration that breaks the currently-deployed version (no expand/contract).
- A new feature merged with only happy-path tests and no failure-mode coverage.

---

## Definition of done — run this checklist before finishing backend work

1. Do dependencies point inward — domain free of framework/DB/transport types? (§1)
2. Are business rules pure, with clock/RNG/IO injected, not called globally? (§2)
3. Is all external input parsed into typed/validated values at the boundary? (§3)
4. Data access: no N+1, indexed hot paths, every list bounded/paginated,
   transaction boundary owned by the use case? (§4)
5. Is the service stateless and horizontally scalable; slow/bursty work queued;
   handlers idempotent; remote calls bounded by timeouts? (§5)
6. Are errors classified to correct status/result, logged with context and a
   correlation ID, with no secrets/PII/stack traces leaked outward? (§6)
7. Config validated at startup; secrets via env/secret manager; least privilege;
   new deps justified and pinned? (§7)
8. Tests: a failing-without-the-change test exists, plus coverage of the
   user-facing failure modes (bad input, not-found/forbidden, duplicates/retries,
   concurrency, downstream failure, pagination)? (§8)

## When NOT to apply this

For a throwaway script, a one-off internal tool, a spike, or a tiny single-purpose
service, full layering (four packages, ports for everything, a mapper per type) is
premature. Match the ceremony to the size and lifetime of the code: keep the
*dependency direction* and *boundary validation* even when you collapse the layers,
and skip the rest deliberately — saying which rule you set aside and why.
