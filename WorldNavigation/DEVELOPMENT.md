# Bundled World Navigation — development must read

Updated 2026-11-21. This is an engineering handoff, not proof of native acceptance.

## Purpose and ownership

Public WorldNavigation is routing/guidance, not private character movement. WorldNavigation.lua owns finite coordinate validation, realm DB, graph validation, planning and N:Request/N:Pump. Terrain.lua owns provider/pack integration. ImageRouting/ImageMaps are explicit map-image estimates; MapArtwork handles available native artwork. CrossZoneRouting composes supported segments. Status owns diagnostic UI and Escape behavior.

## Contracts and previous failures

- Validate finite x/y/map and required z where N:Point is used; reject NaN, infinities, map mismatch and malformed provider records. Missing native projections must return a useful failure rather than throw.
- Preserve node/edge budgets (20,000 nodes and 120,000 edges in the current core), and the 20,000-point generated route budget BEFORE expansion. A shorter graph is not permission for an unbounded interpolated route.
- Repeated terrain subrequest callbacks must complete a segment once. Preserve cancellation generations; stale requests cannot install a route in a new session.
- Saved hazards/blocks are untrusted tables. Validate their shape before use; do not repeat expensive whole-DB validation on every route. Hazards are observed/local information, not a guarantee every unseen threat is represented.
- Image routes have limited coverage and terrain fidelity. Missing packs/projections/artwork do not imply safe terrain or complete world coverage. Do not invent elevation or learned flights.
- Flight Path Finder ships a bundled copy. Update and compare that declared runtime with this source when changing shared behavior. Never replace this API with CombatWorldNavigation or an old development clone.

## Validation

In the private integration workspace run navigation-public, public-runtime-regressions and flights checks plus the manifest audit. Exercise cancellation, duplicate provider callback, missing projection, malformed hazard data, route budget and real image registration. Native checks: actual artwork/projection, map transitions, route display and Escape. Do not claim a safe traversable path from a planner simulation alone.

This is the bundled distribution copy. Canonical shared development is the WorldNavigation repository. Compare runtime files before synchronizing; do not overwrite newer fixes from staging.

## Manifest snapshot (2026-11-21)

Primary: WorldNavigation.toc; compare WorldNavigation_Camelot.toc. Header values and file lists below are a source snapshot; the current TOC wins after a later change.

```text
## Interface: 16001
## Version: 0.1.0-beta.6
## OptionalDeps: Polestar
## SavedVariables: WorldNavigationDB
```

Runtime load order:

- WorldNavigation.lua
- Terrain.lua
- Status.lua
- ImageRouting.lua
- ImageMaps.lua
- MapArtwork.lua
- CrossZoneRouting.lua

## Development rules

Read this guide and the TOC before editing. Treat declared load order, saved-data structure, public/private boundaries and native API restrictions as contracts. Preserve explicit user settings; validate malformed saved data without wiping unrelated history. Never decode secret values or treat unavailable data as success. Do not register restricted raw combat-log events through pcall. Ordinary dashboards must remain closeable in combat; protected descendants stay in separate windows.

An input send, announcement, queued request or local receipt is not proof of native delivery, acceptance or completion. State claims must match their evidence. Bound peer caches, incoming payloads, work queues and retry loops; retain cancellation/request identity for asynchronous work. Add a regression check for a real failure, not a test that merely repeats the implementation.

Source changes are local until explicitly approved for GitHub/CurseForge publication. Keep install ZIPs manifest-driven, verify contents/CRC/hash and compare both client TOCs. Never package private companions or the whole checkout into a public release. Native gameplay and independent-client validation remain separate from offline simulations.

When learning a failure or changing behavior, update this guide with environment, symptom, evidence, fix, affected symbols/tests and remaining validation. User instructions supersede historical design notes.

## Stable push releases — 2026-11-22 (supersedes tag-only guidance)

Owner requests stable public releases on default-branch pushes. Plain X.Y.Z TOC versions now produce CurseForge release and GitHub non-prerelease/latest downloads on default-branch pushes as well as matching version tags. Explicit beta/alpha versions retain their prerelease channels. Feature branches only build artifacts; existing publication gates remain. Branch ZIP/tag labels retain commit hashes to distinguish pushes. Increment the TOC version for subsequent user-facing updates. Both client TOCs must match. Local edits do not publish/promote old remote files; no push/upload was performed. Moderation, compatible game-version metadata and addon-manager matching still affect update availability. Stable channel classification is not proof that pending native acceptance checks passed.
