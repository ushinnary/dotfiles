# UI Engineering Guidelines (JS/TS)

> **Scope.** Read and apply this file whenever you write, refactor, or review
> JavaScript/TypeScript UI code (React, Vue, Svelte, Angular, Solid, or vanilla).
> It is framework-agnostic. Where a principle maps to a framework-specific
> mechanism, that mapping is noted inline. If a rule conflicts with an explicit
> user instruction, the user wins — but say which rule you are setting aside and why.

## Prime directives

1. **Separate things that change for different reasons.** Data fetching, business
   logic, and presentation change on different schedules and for different causes.
   Do not braid them into one unit.
2. **Do not store data you do not own.** Server data is a cache, not your state.
3. **Derive, don't duplicate.** If a value can be computed from existing state,
   compute it. Never keep a second copy in sync by hand.
4. **Fail at the boundary, not in the tree.** Validate and type external data
   where it enters the app, so bad input fails in one obvious place.
5. **Compose, don't configure.** Prefer assembling small pieces over adding flags
   to a big one.
6. **Reuse logic, not markup.** The unit of reuse is behavior, not visual shape.
7. **Don't reimplement solved behavior.** Accessibility, focus, and keyboard
   handling are where bugs concentrate — use vetted primitives.

When these principles point in different directions, prefer the one that keeps
the code **easy to delete and easy to test**.

---

## 1. Split server state from client state

This is the highest-leverage decision in a UI codebase. Most "state management is
hell" pain comes from hand-caching server data in a global store.

- **Server state** (anything that lives on a backend): manage with a query/cache
  layer that handles caching, deduplication, retries, invalidation, and request
  cancellation. _React:_ TanStack Query / SWR. _Vue:_ TanStack Query (Vue) / Pinia
  Colada. _Svelte:_ TanStack Query (Svelte). _Angular:_ TanStack Query (Angular) /
  resource APIs. Never roll this by hand per component.
- **Client state** (UI-only): keep it as local and as small as possible.
  - URL/query params for anything shareable or navigable (filters, tabs, pages).
  - Local component state for the rest.
  - A tiny global store (Zustand/Jotai, Pinia, Svelte stores, signals/services)
    **only** for genuinely cross-cutting UI like theme, auth session, toast queue.

**Avoid this** — manual fetching copy-pasted into every component, with no caching,
no dedup, and hand-rolled race handling:

```ts
// ANTI-PATTERN
let user = null,
  loading = true,
  error = null;
onMount(async () => {
  try {
    user = await (await fetch(`/api/users/${id}`)).json();
  } catch (e) {
    error = e;
  } finally {
    loading = false;
  }
});
// repeated in 30 components, each subtly different
```

**Prefer this** — one reusable query unit; caching and cancellation are free:

```ts
// Define once (custom hook / composable / store), reuse everywhere.
function useUser(id: string) {
  return useQuery({
    queryKey: ["user", id],
    queryFn: () => api.getUser(id), // api layer does validation (see §3)
  });
}
```

**Rule:** if you are about to put server data into a global store, stop. Use the
query layer instead, keyed by its inputs.

---

## 2. Derive state instead of syncing it

A value computed during render cannot go stale. A value copied into state and kept
in sync with an effect is a recurring source of bugs.

```ts
// ANTI-PATTERN: effect syncs derived data; extra render + staleness risk
const [filtered, setFiltered] = useState([]);
useEffect(() => {
  setFiltered(items.filter((i) => i.name.includes(query)));
}, [items, query]);

// PREFER: derive during render
const filtered = items.filter((i) => i.name.includes(query));
// Memoize ONLY if profiling shows it's expensive (React: useMemo;
// Vue: computed; Svelte 5: $derived; Solid: createMemo; Angular: computed).
```

**Effects/watchers are for synchronizing with the outside world** (DOM, timers,
subscriptions, logging, non-reactive libraries) — not for reacting to your own
state to set more state. If an effect's only job is `setX` based on props/state,
it is almost certainly wrong; derive instead, or compute during the event handler
that caused the change.

---

## 3. Validate and type at the network boundary

Parse external data (API responses, `localStorage`, URL params, postMessage,
env) at the edge. A bad payload should throw at the boundary, not surface as
`Cannot read properties of undefined` three layers deep.

```ts
import { z } from "zod"; // or valibot, arktype, io-ts — any runtime validator

const User = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
});
type User = z.infer<typeof User>;

export async function getUser(id: string): Promise<User> {
  const res = await fetch(`/api/users/${id}`);
  if (!res.ok) throw new ApiError(res.status);
  return User.parse(await res.json()); // single, loud failure point
}
```

- The validated type is the **single source of truth** — derive TS types from the
  schema, don't hand-write a parallel `interface`.
- Keep the data/api layer separate from components. Components consume typed data;
  they do not call `fetch` directly.

---

## 4. Compose over prop/flag explosion

Boolean and label props multiply combinatorially and force the component to
anticipate every use. Expose structure instead.

```tsx
// ANTI-PATTERN: every new need adds another prop
<Modal title="…" showClose showFooter primaryLabel="OK"
       secondaryLabel="Cancel" onPrimary={…} onSecondary={…} size="lg" />

// PREFER: open composition (React compound components / Vue & Svelte slots /
// Angular content projection with <ng-content>)
<Modal>
  <Modal.Header>Confirm</Modal.Header>
  <Modal.Body>Are you sure?</Modal.Body>
  <Modal.Footer>
    <Button onClick={cancel}>Cancel</Button>
    <Button variant="primary" onClick={ok}>OK</Button>
  </Modal.Footer>
</Modal>
```

Guidance: a 1–3 prop component does **not** need slots — composition there is just
noise. Reach for composition when you notice props that only exist to toggle the
presence or arrangement of children, or when prop combinations are becoming
invalid/contradictory.

---

## 5. Extract logic into reusable units

The real antidote to copy-paste is reusing **behavior**, not splitting templates.
Pull stateful or side-effecting logic into a named unit and reuse it.

- _React:_ custom hooks (`useDebouncedValue`, `usePagination`).
- _Vue:_ composables (`useDebouncedValue`).
- _Svelte 5:_ functions returning runes / `.svelte.ts` modules.
- _Angular:_ services or signal-based helpers.
- _Solid:_ primitives (`createDebounced`).

```ts
// One definition, reused everywhere — instead of re-pasting timeout logic.
function useDebouncedValue<T>(value: T, ms = 300): T {
  const [v, setV] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setV(value), ms);
    return () => clearTimeout(t);
  }, [value, ms]);
  return v;
}
```

A unit of logic should have **one reason to exist** and a name that states it.
If you can't name it crisply, it's doing too much — split it.

---

## 6. Use headless / accessible primitives for interactive widgets

Dropdowns, dialogs, comboboxes, tabs, tooltips, popovers: the focus management,
keyboard interaction, and `aria-*` wiring are subtle, get re-broken on every
hand-roll, and are the densest source of accessibility bugs.

- Use a headless/behavior library and supply your own styling: Radix, React Aria,
  Headless UI, Ark UI, Melt UI (Svelte), Angular CDK, Kobalte (Solid), etc.
- Do **not** hand-build a custom `<select>`, modal focus trap, or autocomplete
  unless explicitly asked and told the trade-off is accepted.
- Native elements first: a `<button>`, `<dialog>`, `<details>`, or
  `<a href>` is better than a div with click handlers.

---

## 7. Organize by feature, split smart from dumb

Co-locate everything a feature needs; do not scatter it across `components/`,
`hooks/`, `utils/`, `types/` trees by file type.

```
features/
  user-profile/
    UserProfile.view.tsx     # presentation: data in via props, markup out
    useUserProfile.ts        # logic: queries, mutations, derived values
    user.api.ts              # fetch + schema/validation (§3)
    user.types.ts            # types derived from schema
    UserProfile.test.tsx
```

- **Presentational** units take data and callbacks via props and render. They do
  not fetch, and ideally hold no business logic — making them trivial to test and
  cheap to throw away.
- **Container/logic** units own data and decisions and pass results down.
- Shared, truly-generic pieces (design-system Button, the query client, the
  validator setup) live in a `shared/` or `ui/` root, not inside a feature.

---

## 8. Prefer what the component library already gives you

If the project depends on a component or design-system library (MUI, Mantine,
Chakra, Ant, shadcn/ui, PrimeVue, Vuetify, Angular Material, Bootstrap, Tailwind +
a component kit, etc.), use what it ships **before** writing anything custom. The
library is the convention; custom code that duplicates it fragments the design
system, drifts on upgrades, and re-opens bugs the library already closed.

- **Components first.** Need a button, modal, table, tabs, form field? Use the
  library's component. Do not hand-roll a parallel one with raw elements + custom
  CSS when the library exports it.
- **Its classes / tokens / props for styling.** Style with the library's utility
  classes, variant props, theme tokens, or `sx`/style API — not a bespoke
  stylesheet that hardcodes colors, spacing, or breakpoints the theme already
  defines. Spacing, color, typography, and radius should come from the theme, not
  magic numbers.
- **Extend through its supported seams.** Customize via the library's theming,
  variants, slots, or class-override hooks. Reach for custom CSS only for genuinely
  novel UI the library has no answer for — and say so when you do.
- **One source of visual truth.** Don't mix a custom `.btn` class next to the
  library's `<Button>`; pick the library and stay consistent.

Before writing a new component or a CSS rule, check whether the library already
provides it (component, prop, variant, or class). If it does, use that. This is the
visual-layer counterpart to §6 (headless primitives) and the "don't reimplement
solved behavior" prime directive.

---

## Anti-patterns to flag or refuse on sight

- Server data placed in a global/Redux-style store "to share it."
- An effect/watcher whose body is just `setState` from props or other state.
- A component that fetches, transforms, applies business rules, **and** renders.
- Prop drilling solved by wrapping everything in a single broad Context/provider
  that re-renders all consumers. (Split contexts by concern, or pass children.)
- `any`, unchecked `as` casts, or `@ts-ignore` to silence boundary errors instead
  of validating the data.
- Reaching for `useMemo`/`computed`/memo wrappers everywhere "for performance"
  before any measurement.
- Indexes as keys in dynamic, reorderable lists.
- Business logic embedded in JSX/templates (compute it above, render the result).
- Reimplementing a dropdown/modal/combobox by hand.
- Hand-writing a component or custom CSS class when the project's component library
  already ships that component, prop, variant, or utility class (§8).
- Hardcoded colors/spacing/breakpoints in custom CSS when the library's theme tokens
  already define them.

---

## Definition of done — run this checklist before finishing UI work

1. Is any server data being hand-cached in component/global state? → move to the
   query layer (§1).
2. Does any effect/watcher exist only to copy or sync state? → derive instead (§2).
3. Is external data validated and typed where it enters? → add boundary parsing (§3).
4. Are there flag/boolean props that could be composition? → reconsider (§4).
5. Is any non-trivial logic duplicated across components? → extract a hook/
   composable/primitive (§5).
6. Are interactive widgets built on accessible primitives, with keyboard + focus
   working and correct ARIA? (§6)
7. Can each presentational unit be rendered and tested with plain props, no network?
   (§7)
8. Types: no `any`/unsafe casts at boundaries; types derived from schemas where
   relevant.
9. If a component library is in use: is every component, style, and token drawn from
   it rather than hand-rolled or custom-CSS'd where it already provides one? (§8)

## When NOT to apply this

For a single-screen prototype, a throwaway script, or a tiny widget, several of
these (feature folders, a query library, strict boundary validation, compound
components) are premature. Match the ceremony to the size and lifetime of the
code. If the app or team is small and short-lived, prefer the simplest thing that
works and note that you skipped a rule deliberately.
