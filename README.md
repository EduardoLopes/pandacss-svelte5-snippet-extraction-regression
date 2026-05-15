# Panda CSS — `$`-prefixed identifier extraction regression in 1.11.0

`css({...})` calls are no longer extracted from `.svelte` files whose `<script>` block references any identifier starting with `$` — every Svelte 5 rune (`$state`, `$derived`, `$effect`, `$props`) trips it, but so does a plain user-defined `function $myFn() {}`. Template directives such as `{@render ...}`, `{#if ...}`, and `{:else}` are **not** triggers on their own. An identifier appearing only inside a string literal also does not trigger the failure.

- **Last working:** `@pandacss/dev@1.10.0`
- **First broken:** `@pandacss/dev@1.11.0`
- Also broken: `@pandacss/dev@1.11.1`

## Symptoms

`panda cssgen` aborts with:

```
Could not find source file: '<abs path>/src/SomeComponent.svelte'.
 ELIFECYCLE  Command failed with exit code 1.
```

…even though the file exists on disk.

In a real Vite + PostCSS dev server the same parse failure is silent: affected files contribute **no** rules to the output, while unaffected files in the same project extract normally. The end-user symptom is "some `css({...})` calls work, others don't".

## Reproduce

```sh
pnpm install       # installs @pandacss/dev@1.11.1
pnpm cssgen        # ❌ throws on the first rune-using file it encounters
```

Switch back to the last working version:

```sh
pnpm repro:works   # pins @pandacss/dev@1.10.0
```

`dist.css` is produced and contains rules from every source file.

## Per-probe report

Run `pnpm report [version]`. The script narrows `include` to one `.svelte` file at a time and runs `panda cssgen` on each, then prints a pass/fail table. Exit code is the number of failing files.

```sh
pnpm report            # tests the currently-installed @pandacss/dev
pnpm report 1.10.0     # installs the version first, then tests it
pnpm report 1.11.1
```

Output on `1.11.1`:

```
File                                          panda cssgen
----                                          ------------
baseline-no-runes.svelte                      ✅ extracted (1 color rule[s])
probe-derived.svelte                          ❌ throws "Could not find source file"
probe-dollar-identifier.svelte                ❌ throws "Could not find source file"
probe-effect.svelte                           ❌ throws "Could not find source file"
probe-props.svelte                            ❌ throws "Could not find source file"
probe-state-call-no-let.svelte                ❌ throws "Could not find source file"
probe-state.svelte                            ❌ throws "Could not find source file"
probe-string-state.svelte                     ✅ extracted (1 color rule[s])
probe-template-else.svelte                    ✅ extracted (1 color rule[s])
probe-template-if.svelte                      ✅ extracted (1 color rule[s])
probe-template-render.svelte                  ✅ extracted (1 color rule[s])

5 ok, 6 failing on @pandacss/dev@1.11.1
```

On `1.10.0` the same script reports `11 ok, 0 failing`.

| Probe | Result on 1.11.1 |
| --- | --- |
| no `$`-prefixed identifiers (baseline) | ✅ extracts |
| `let count = $state(0)` | ❌ throws |
| `let doubled = $derived(...)` | ❌ throws |
| `$effect(() => {...})` | ❌ throws |
| `let { x }: { x?: boolean } = $props()` | ❌ throws |
| `$state(0);` as an expression statement | ❌ throws |
| `function $myFn(n) {...}; $myFn(21);` (not a rune) | ❌ throws |
| `'let count = $state(0);'` (only inside a string literal) | ✅ extracts |
| template `{@render ...}` with no `$` in script | ✅ extracts |
| template `{#if ...}{/if}` with no `$` in script | ✅ extracts |
| template `{#if ...}{:else}{/if}` with no `$` in script | ✅ extracts |

Every file with a top-level reference to a `$`-prefixed identifier fails. The Svelte runes (`$state`, `$derived`, `$effect`, `$props`) all fail, but so does a user-defined `function $myFn() {}` that has nothing to do with Svelte. An identifier mentioned only inside a string literal is fine. Template directives by themselves do not trigger the failure.

## Bisect

| `@pandacss/dev` | `panda cssgen` |
| --- | --- |
| 1.10.0 | ✅ |
| **1.11.0** | **❌** |
| 1.11.1 | ❌ |

No `1.10.x` patch releases were published — the regression boundary is `1.10.0` → `1.11.0`.

## Files

- [`panda.config.ts`](panda.config.ts) — minimal config (no preset, no PostCSS, no preflight tweaks).
- [`src/baseline-no-runes.svelte`](src/baseline-no-runes.svelte) — control: no `$`-prefixed identifiers.
- [`src/probe-state.svelte`](src/probe-state.svelte) — `$state(...)` rune.
- [`src/probe-derived.svelte`](src/probe-derived.svelte) — `$derived(...)` rune.
- [`src/probe-effect.svelte`](src/probe-effect.svelte) — `$effect(...)` rune.
- [`src/probe-props.svelte`](src/probe-props.svelte) — `$props()` rune.
- [`src/probe-state-call-no-let.svelte`](src/probe-state-call-no-let.svelte) — `$state(0);` as a bare expression.
- [`src/probe-dollar-identifier.svelte`](src/probe-dollar-identifier.svelte) — user-defined `$myFn`, not a rune.
- [`src/probe-string-state.svelte`](src/probe-string-state.svelte) — `$state` only inside a string literal.
- [`src/probe-template-render.svelte`](src/probe-template-render.svelte) — `{@render ...}` in template, no `$` in script.
- [`src/probe-template-if.svelte`](src/probe-template-if.svelte) — `{#if ...}` in template, no `$` in script.
- [`src/probe-template-else.svelte`](src/probe-template-else.svelte) — `{#if}...{:else}` in template, no `$` in script.
- [`scripts/report.sh`](scripts/report.sh) — per-file isolation test runner.

## Environment

- Node 24.15.0, pnpm 10.22.0, TypeScript 5.9.3 (also reproduced on 6.0.3)
- Svelte 5.43.3
- macOS 25.4.0 (Darwin)
