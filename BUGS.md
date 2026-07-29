# Bugs

Defect log for FCA-PRO. Add a row when a bug is found, fill in the fix commit
when it lands. Entries 1-7 predate this repo and were reconstructed from session
notes, so their causes are recorded but there is no commit to point at.

Counting rule: one row per distinct defect, not per commit. A commit that fixed
three separate things gets three rows.

## Open

None.

## Fixed

| # | Found | Symptom | Cause | Fixed in |
|---|-------|---------|-------|----------|
| 1 | 2026-06-13 | iPad zoomed in every time a field was tapped | Touch CSS put inputs at 14px; Safari auto-zooms anything under 16px | pre-repo |
| 2 | 2026-06-13 | 6 of 7 buildings showed as unassigned | The old New Building form saved `campus_id` as `"id\|name"`; the picker now stores a clean id | pre-repo |
| 3 | 2026-06-14 | Auto-save silently stopped working on iPad | 7 full-res base64 photos made a 30MB store, over iOS Safari's ~5MB localStorage cap; photos are now resized to 1280px q0.7 on capture and on import | pre-repo |
| 4 | 2026-06-16 | Black screen opening the file from iOS Files | Top-level `localStorage` read threw `SecurityError` on a `file://` origin and killed the script before React mounted; reads now go through `lsGet`/`lsSet` | pre-repo |
| 5 | 2026-06-16 | Add item, press Save, whole screen goes blank | The iOS HTML viewer's WebKit has no `console.warn`; calling it as the first line of `saveStore`'s catch threw during the render phase, so React unmounted the root. Console polyfill added, plus a permanent `ErrorBoundary` | pre-repo |
| 6 | 2026-06-16 | No way to reach nav on iPhone | The only mobile rule was `.sidebar{display:none}`, and the sidebar holds page nav and the building selector; replaced with a slide-in drawer | pre-repo |
| 7 | 2026-06-16 | Export produced no file on iOS | `a.download` is ignored on iOS Safari, and the synchronous `revokeObjectURL` after `click()` cancelled the save; now tries the Web Share API first with a deferred-revoke fallback | pre-repo |
| 8 | 2026-06-22 | Sync could wipe the cloud copy | `push()` treated an empty local store with a surviving shadow as mass deletion; it now suppresses the deletes and forces a recovery re-pull | b3e5939 |
| 9 | 2026-06-22 | Sync froze permanently after one bad request | A stalled Supabase request wedged `_busy` with no timeout; all requests now use a 25s AbortController | b3e5939 |
| 10 | 2026-06-22 | Newer server edits lost to older local ones | Conflicts always preferred the local copy; now arbitrated by recency using per-record `localTs` vs server `updated_at` | b3e5939 |
| 11 | 2026-07-14 | Wrong theme flashed on load, scanline overlay sat above content | Theme applied after first paint; overlay z-order | a610518 |
| 12 | 2026-07-26 | Impact and Risk pills gave no feedback when tapped | No selected-state CSS on `.rp` | 4144aa6 |
| 13 | 2026-07-26 | Editing an item dropped fields that were not on screen | Item update replaced the record instead of merging | 4144aa6 |
| 14 | 2026-07-26 | Picking from the catalog wiped a half-filled item | Catalog pick reset the whole draft | 4144aa6 |
| 15 | 2026-07-26 | Linked item lost the original item's deficiencies | Linked-item creation did not re-assert them | 4144aa6 |

## Investigated, not a bug

| Reported | Finding |
|----------|---------|
| Backup JSON has 0 items | Expected. Assessment items get created in the field; the seed carries buildings only |
| Black screen opening the HTML from Mail or Files | iOS Quick Look renders HTML with JavaScript disabled. Open in Safari, or install from the hosted URL |
| Data lost on reload from a local file | `file://` cannot persist to localStorage on iOS. Use the hosted URL or the Export/Import JSON workflow |

## Verifying a fix

No JS engine on this box can parse the app (rhino is ES5-only), so:

1. `python3 fca-pro-tools/validate.py <baseline> index.html` - string-aware
   delimiter signature compare against the pre-edit file. Must print MATCH.
2. Serve and run the real app headlessly:
   `python3 -m http.server 8765 --bind 127.0.0.1` then
   `WEBKIT_DISABLE_COMPOSITING_MODE=1 GDK_BACKEND=x11 LIBGL_ALWAYS_SOFTWARE=1 python3 harness.py`.
   `final_errors` must report an empty `errs` list.

The harness stubs `fetch`/XHR to anything but 127.0.0.1, so a test run cannot
write into the live Supabase project.
