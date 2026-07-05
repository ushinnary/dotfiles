# Architecture Guidelines

> **Scope.** Read and apply this file when making structural decisions about a
> codebase or system: module and service boundaries, dependency direction, where a
> responsibility lives, how parts communicate, how the system evolves, or any "how
> should this be organized?" question. Language-, framework-, and tier-agnostic
> (applies to a library, a CLI, a frontend, a backend, a monolith, or a distributed
> system). If a rule conflicts with an explicit user instruction, the user wins —
> but say which rule you are setting aside and why.
>
> This is the system-scale companion to `BACKEND_GUIDELINES.md` (which covers
> layering *within* a service). For a deliberate restructuring effort, use the
> `improve-architecture` skill; this guide is the standard those changes aim for.

## Prime directives

1. **Optimize for change, not for now.** The first job of architecture is to make
   the likely future changes cheap and the dangerous ones contained. Code is read
   and modified far more than it is written.
2. **High cohesion, low coupling.** Things that change together live together;
   things that change independently stay apart and talk through narrow contracts.
3. **Depend on abstractions, and let dependencies point one way.** Stable, abstract
   things are depended upon; volatile, concrete things do the depending. No cycles.
4. **Boundaries are where you spend your design budget.** The interfaces *between*
   modules matter more than the code inside them — a clean boundary lets you rewrite
   either side.
5. **Each piece owns its data and decisions.** One module is the source of truth for
   a given concept; others ask it, they don't reach in.
6. **Defer the big, irreversible calls.** Choose the simplest structure that fits
   what you know now; keep the expensive decisions (database, distribution, vendor)
   behind a seam so they can change.
7. **Make the architecture visible.** The structure should be legible from the
   directory layout and the dependency graph, and the non-obvious *why* recorded.

When these point in different directions, prefer the option that is **easiest to
reverse** and keeps modules **independently understandable and replaceable**.

---

## 1. Boundaries, modularity, and cohesion

The core architectural act is drawing lines: deciding what is inside a module and
what is outside, and what crosses the line.

- **Organize by capability, not by technical layer.** Group code by what it does for
  the domain (`billing/`, `search/`, `notifications/`), not by file kind
  (`controllers/`, `models/`, `utils/`). Feature/domain grouping co-locates what
  changes together and keeps a change in one place.
- **High cohesion inside a module:** everything in it serves one purpose and changes
  for one set of reasons. If a module changes for many unrelated reasons, it is
  doing too many jobs — split it.
- **A module exposes an intentional surface.** A small, explicit public API (exports,
  a facade, an interface); everything else is internal and free to change. Treat the
  public surface as a contract.
- **The size test:** a module you cannot describe in one sentence, or whose name is
  `common`/`utils`/`misc`/`helpers`, is an unowned junk drawer — name it for what it
  does or break it up.

---

## 2. Coupling: minimize it, and pick the loose kind

Coupling is what makes one change ripple into ten files. You cannot eliminate it —
you choose where it lives and how tight it is.

- **Couple to contracts, not to internals.** Modules interact through a published
  interface (function signature, API schema, message format), never by reaching into
  each other's data structures or private state.
- **Prefer the loosest coupling that works:** an event or message (sender doesn't
  know the receiver) over a direct call (caller knows the callee) over shared mutable
  state (everyone knows everyone — the tightest, worst kind).
- **Hide implementation choices.** A module's database, libraries, and algorithms are
  its private business; if changing them forces changes in callers, the boundary
  leaked.
- **Watch for the telltale ripple:** if a one-line behavior change touches many
  unrelated files, coupling is too high — that's a design signal, not a chore.
- **Don't over-decouple, either.** Indirection has a cost in legibility. Add a seam
  where change or substitution is *likely*, not everywhere "just in case" (§7).

---

## 3. Dependency direction and abstraction

The shape of the dependency graph determines whether the system is changeable or a
tangle.

- **Dependencies point toward stability.** Volatile, concrete, detail-heavy code
  depends on stable, abstract policy — never the reverse. Business rules don't depend
  on the web framework or the database; those depend on interfaces the core defines
  (dependency inversion; see `BACKEND_GUIDELINES.md` §1).
- **No cycles.** A dependency cycle between modules means they are really one module
  with a false border — merge them or introduce an abstraction to break the loop.
  Acyclic dependencies keep the system buildable, testable, and reasoned-about in
  pieces.
- **Abstract at the points of likely change** (the database, a third-party vendor, a
  delivery mechanism) so the concrete choice sits behind a seam and can be swapped.
- **Depend on what you use, not the world.** Narrow interfaces over broad ones; a
  consumer shouldn't drag in a god-object to call one method.
- **Keep the stable core small.** The things everything depends on should change
  rarely; if your most-depended-upon module changes every week, the whole system
  churns with it.

---

## 4. Data and state ownership

Most architectural decay starts as data leaking across boundaries.

- **One owner per piece of data.** Exactly one module/service is the source of truth
  for a given concept; everyone else holds a derived copy or asks the owner. Two
  writers for one fact is a corruption bug waiting to happen.
- **Don't share a database across service boundaries.** Sharing tables couples
  services at their most rigid point (the schema). Each owns its store and exposes
  data through an API/event, or it isn't really a separate service.
- **Separate the contract from the storage shape.** The model you expose (API DTO,
  event payload) evolves on a different schedule than how you store it; map between
  them so internal refactors don't break consumers.
- **Make the flow of data explicit and one-directional** where you can; tangled
  bidirectional data flow between modules is the hardest thing to reason about.
- **Keep state at the right altitude:** as local as possible, promoted to a shared/
  global owner only when genuinely cross-cutting (mirrors `UI_GUIDELINES.md` §1 and
  `BACKEND_GUIDELINES.md` §5).

---

## 5. Communication and contracts between parts

How parts talk is itself an architectural decision with consequences for coupling,
failure, and evolvability.

- **Synchronous call vs. asynchronous message is a real choice.** Direct/sync calls
  are simple and give immediate consistency but couple availability (your callee's
  outage is your outage). Events/queues decouple and absorb load but add eventual
  consistency and ordering concerns. Choose deliberately, not by habit.
- **Contracts are versioned and evolve compatibly.** Add fields, don't repurpose or
  remove them without versioning. A published interface (API, event, library export)
  has consumers you may not see — changing it is a breaking change until proven
  otherwise.
- **Design for partial failure at every remote boundary:** timeouts, retries with
  backoff, idempotency, and a defined behavior when the other side is down
  (`BACKEND_GUIDELINES.md` §5, `CONCURRENCY_GUIDELINES.md` §5). A network call is not
  a function call.
- **Keep chatter low.** A boundary crossed N times per operation (the distributed
  N+1) is a latency and coupling problem; design coarse-grained interactions across
  expensive boundaries.

---

## 6. Designing for change and evolution

- **Separate what varies from what stays the same.** Isolate the parts you expect to
  change (pricing rules, integrations, UI skins) behind a stable interface so change
  is additive and local.
- **Prefer extension over modification.** Adding a case should mean adding code
  (a new implementation of an interface), not editing a sprawling `switch` in ten
  places. But don't build the plugin system before the second plugin exists (§7).
- **Make changes reversible and incremental.** Favor migrations that can roll back
  (expand → migrate → contract), feature flags for risky paths, and strangler-style
  replacement over big-bang rewrites.
- **Record the decisions, not just the code.** Capture significant architectural
  choices and their *why* — the options weighed and the trade-off accepted — in a
  short durable note (an ADR / decision log). The next person needs the reasoning,
  not to reverse-engineer it (`AGENTS.md` §6).
- **Conway's law is real:** the system will mirror the team's communication
  structure. Draw module boundaries you can actually staff and own.

---

## 7. Manage complexity — the simplest structure that fits

Architecture is as much about what you *don't* build. Accidental complexity — the
kind you added, not the kind the problem demands — is the primary enemy.

- **Start simple; let structure earn its place.** A well-organized monolith beats a
  premature distributed system. Introduce a service boundary, a layer, or an
  abstraction when there is concrete pressure for it (independent scaling,
  deployment, ownership, or a second real use case), not in anticipation.
- **An abstraction needs at least two real call sites** before it exists
  (`AGENTS.md` §3). One speculative generalization is a guess that usually guesses
  wrong and costs more to unwind than it saved.
- **YAGNI over speculative flexibility.** Don't add config knobs, plugin points, or
  layers of indirection for futures that may never come; they are pure cost today
  and a liability if the future differs.
- **Distribution is a last resort, not a default.** Network boundaries buy
  independent scaling and deployment at the price of latency, partial failure,
  debugging difficulty, and operational burden. Don't pay it without the benefit.
- **Be boring and consistent.** One way to do a common thing across the codebase
  beats three clever ones. Consistency is an architectural property: it makes the
  whole system learnable from any part of it.

---

## Anti-patterns to flag or refuse on sight

- Organizing by technical layer (`controllers/`, `models/`, `utils/`) so one feature
  scatters across the tree.
- A `utils`/`common`/`misc` module that is an unowned grab-bag of unrelated code.
- A dependency cycle between modules (they are secretly one module).
- A "god" module/object everything depends on and that changes constantly.
- Two modules/services writing the same data, or sharing a database schema across a
  service boundary.
- Reaching into another module's internals/private state instead of its public
  contract.
- A breaking change to a published API/event/export with no versioning or
  compatibility path.
- Premature microservices, layers, plugin systems, or config knobs for needs that
  don't exist yet.
- A single broad abstraction with one call site, built "for the future".
- Significant architectural decisions made with no record of the reasoning.

---

## Definition of done — run this checklist before finishing structural work

1. Is the code organized by capability/domain, with each module cohesive and
   describable in one sentence? (§1)
2. Do modules interact through narrow published contracts, not shared internals or
   shared mutable state — with the loosest coupling that works? (§2)
3. Do dependencies point toward stable abstractions, with **no cycles**, and seams at
   the points of likely change? (§3)
4. Does each piece of data have exactly one owner, with no cross-boundary database
   sharing and contract-vs-storage separated? (§4)
5. Are communication style (sync vs async) and contract versioning chosen
   deliberately, with partial-failure handling at remote boundaries? (§5)
6. Is the design reversible/incremental, with what-varies isolated and significant
   decisions recorded (ADR)? (§6)
7. Is this the simplest structure that fits — no speculative services, layers, or
   abstractions; every abstraction earning its keep? (§7)

## When NOT to apply this

A throwaway script, a prototype, a one-off tool, or a small short-lived codebase does
not need module boundaries, dependency-inversion seams, ADRs, or service splits —
imposing them is exactly the accidental complexity §7 warns against. Match the
structure to the size, lifetime, and number of contributors. The smallest viable
architecture that keeps the *dependency direction* sane is usually the right one;
add structure when real pressure (scale, team size, change rate) demands it, and say
which rule you set aside and why.
