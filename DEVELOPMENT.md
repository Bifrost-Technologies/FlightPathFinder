# Flight Path Finder repository — must read

## Purpose and ownership

Public map/directory and route guidance only. FlightPathFinder.lua owns node definitions/discovery, Map/Interface/Minimap display them, Pathing owns F:RouteTo/F:StopPath, MinimapRoute and WorldGuidance project guidance. Character-specific discovery lives in FlightPathFinderCharDB; account settings are separate.

## Contracts and previous failures

- A flight node is learned only from explicit native taxi data. Arrival, map proximity, a successful route or a guessed faction path is not discovery evidence. Unknown discovery stays unknown.
- Validate saved nodes/discoveryEvidence/approaches tables and saved points. Do not wipe other characters when repairing one malformed child table.
- Validate asynchronous routes: 2..20,000 valid points, correct map/coordinate contract, usable route-source label. Reject malformed callbacks and ignore cancelled/old generations.
- Optional WorldNavigation may be unavailable or lack coverage. Keep actionable fallback reasons. Its bundled copy must match reviewed shared source; do not duplicate a nested versioned addon directory.
- Automatic walking/flight discovery automation belongs to the private runner and must never enter this public addon or ZIP.

## Build and validation

release.json declares FlightPathFinder AND WorldNavigation as top-level folders. The maintained layout uses subfolders; old root-level source layouts are not the current install package. Use the shared scripts/release.py/Build.ps1 workflow, compare TOCs and verify the ZIP. Tests: flights, navigation-public and public-runtime-regressions. Native checks: actual taxi updates, unavailable/unknown nodes, cancelling/restarting route display, zone/faction differences and map/minimap rendering.

Read each affected addon folder's DEVELOPMENT.md and its TOC. release.json is the packaging source of truth. Development documentation belongs in source review even when install ZIPs omit it.

## Development rules

Read this guide and the TOC before editing. Treat declared load order, saved-data structure, public/private boundaries and native API restrictions as contracts. Preserve explicit user settings; validate malformed saved data without wiping unrelated history. Never decode secret values or treat unavailable data as success. Do not register restricted raw combat-log events through pcall. Ordinary dashboards must remain closeable in combat; protected descendants stay in separate windows.

An input send, announcement, queued request or local receipt is not proof of native delivery, acceptance or completion. State claims must match their evidence. Bound peer caches, incoming payloads, work queues and retry loops; retain cancellation/request identity for asynchronous work. Add a regression check for a real failure, not a test that merely repeats the implementation.

Source changes are local until explicitly approved for GitHub/CurseForge publication. Keep install ZIPs manifest-driven, verify contents/CRC/hash and compare both client TOCs. Never package private companions or the whole checkout into a public release. Native gameplay and independent-client validation remain separate from offline simulations.

When learning a failure or changing behavior, update this guide with environment, symptom, evidence, fix, affected symbols/tests and remaining validation. User instructions supersede historical design notes.

## Stable push releases — 2026-11-22 (supersedes tag-only guidance)

Owner requests stable public releases on default-branch pushes. Plain X.Y.Z TOC versions now produce CurseForge release and GitHub non-prerelease/latest downloads on default-branch pushes as well as matching version tags. Explicit beta/alpha versions retain their prerelease channels. Feature branches only build artifacts; existing publication gates remain. Branch ZIP/tag labels retain commit hashes to distinguish pushes. Increment the TOC version for subsequent user-facing updates. Both client TOCs must match. Local edits do not publish/promote old remote files; no push/upload was performed. Moderation, compatible game-version metadata and addon-manager matching still affect update availability. Stable channel classification is not proof that pending native acceptance checks passed.
