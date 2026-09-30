# Methodology Alignment Framework

What has to change in FCA-PRO so the app matches `FCA_Pro_Methodology.docx` (the
standard AEFCA rating framework, now reproduced in-app under Docs → Methodology)
instead of just the ad-hoc rating language the app grew on its own. The White
Paper (`FCA_Pro_White_Paper_Final_External.docx`) is now live under Docs →
Whitepaper — no code follows from it beyond the export-format and
integration items pulled into Tier 4 below.

Tier = how soon it should land. Effort is a rough shape, not a quote.

## Status

### Done
- [x] White Paper inserted — Docs → Whitepaper (Pete's external doc, verbatim)
- [x] Methodology inserted — Docs → Methodology (verbatim, plus the pre-existing
      BC scale / FCI / MDI / BQI reference material carried forward as §17–21,
      clearly marked as "current implementation," not part of the standard itself)
- [x] **1.2** LoF/CoF relabel — "Impact of Failure"/"Risk of Failure" pills are now
      "Consequence of Failure (CoF)"/"Likelihood of Failure (LoF)" with the
      Methodology's definitions as inline hints; table columns shortened to CoF/LoF
- [x] **2.1** Mission/Function categories — replaced with the Methodology §7 list
      verbatim (added Clinical/Patient Care, Public Safety, Food Service, Data/IT;
      dropped "Public Image," which isn't a mission category)
- [x] **2.2** Lifecycle traceability — added Catalog EUL (auto-filled from the
      catalog pick) and Revised In-Service Yr; Lifecycle Yrs now shows "adjusted
      from catalog Xyr" whenever the assessor's value diverges from the default
- [x] **2.3** Deficiency Cost vs. Developed Project Cost — Projects have an
      optional Additional Scope Cost field; when set, the project card shows
      Developed Project Cost as the headline with a Deficiency + scope breakdown
- [x] **3.1** Capital plan horizon bands — the 10-year chart now visually splits
      years 1–5 (detailed plan) from 6–10 (outlook), matching Whitepaper §6
- [x] CSV export — every assessed item, portfolio-wide, from the topbar
- [x] **1.1** Condition scale — 6-point BC1–BC6 collapsed to the Methodology's
      5-point BC1–BC5 (Excellent/Good/Fair/Poor/Urgent-Critical). Decided directly
      by Wes ("5 point, match methodology") rather than left open for Pete. Old
      BC3 "Adequate" items keep their stored value (now read as Fair) but are
      tagged `_bc_migrated:'adequate'` for manual assessor review rather than
      silently reassigned; BC4–BC6 shift down one slot (Fair→Fair, Poor→Poor,
      Fail→Urgent/Critical). Migration runs automatically, once, for existing
      local data and any future JSON import — no user action required. Touched
      every BC-scale constant, palette, iteration array, and the ~20 sites that
      reused BC5/BC6 purely as "the orange/red color" for FCI bands or priority
      (unrelated to item condition, shifted the same way for consistency). Docs →
      Methodology §17 updated to the 5-point table; the old divergence note is gone.

### Still needed — blocked on Pete

The Methodology's own §15 ("Client-Specific Configuration") matters here: it
explicitly says condition scales, priority structures, LoF/CoF definitions, and
scoring weights are all things FCA Pro is *meant* to let a program configure —
"when a client already has an established FCA methodology, the platform can be
aligned to that approach." That changes how the items below should be read: none
of them are obviously bugs to fix — they might just be *this program's
configuration* — and reshaping them without checking would be wasted, possibly
actively wrong, work.
- [ ] **1.3 priority model** — same configuration question for the 7-tier priority
  field. If it should split, confirm P6/P7 (New Construction / ADA) really belong
  as flags rather than priority, and confirm P4/P5 should come from lifecycle math
  instead of being hand-assigned.
- [ ] **1.4 Overall Deficiency Score** — the Methodology explicitly leaves weights and
  thresholds unset ("established as the FCA Pro baseline is finalized"). Can't
  write the formula without those numbers from Pete/AEFCA.
- [ ] **3.2 catalog code format** — is the flat UNIFORMAT code sufficient, or does a
  concrete roll-up need actually require the concatenated Level 5 ID format? Don't
  touch the ~2,900-item catalog without a real reporting requirement driving it.
- [ ] **CMMS/IWMS/EAM/GIS integration** — Whitepaper frames this as established
  per-client; no code to write until a specific client/system is in view.
- [ ] **ODT export** — Whitepaper §9 lists it alongside CSV/PDF; CSV shipped, ODT
  didn't (lower value, no client asking for it yet).

The rest of this document is the full detail behind both lists.

## Tier 1 — Rating vocabulary (do first; everything else in the Methodology assumes these exist)

### 1.1 Condition scale: 6-point → 5-point — DONE
**Was:** `BC1–BC6` — Excellent / Good / **Adequate** / Fair / Poor / Fail.
**Methodology §4:** 5 ratings — Excellent / Good / Fair / Poor / **Urgent-Critical**.
**Now:** `BC1–BC5` — Excellent / Good / Fair / Poor / Urgent-Critical, matching the
Methodology exactly.
**Resolution decided:** Wes chose the direct answer ("5 point, match methodology")
rather than leaving this open for Pete — §15 client-configuration still applies in
principle, but this program is standardizing on the Methodology's own scale.
**How the migration actually works (not a manual re-rate screen, per the original
proposal — a lighter automatic pass instead):**
- Unambiguous shifts happen silently: old Fair(BC4)→BC3, Poor(BC5)→BC4,
  Fail(BC6)→BC5. No meaning changes for these, only the numbering.
- The one ambiguous case — old BC3 "Adequate" — is **not** auto-resolved to Good or
  Fair. It keeps its stored value (now displayed/read as Fair, the nearest
  Methodology tier) but gets tagged `_bc_migrated:'adequate'` on the record, a
  breadcrumb for a future "needs review" filter/report rather than a blocking
  screen. Per-item assessor resolution, just deferred instead of forced at load time.
- Runs once, automatically, in both `loadStore()` (existing local data) and
  `importData()` (any future JSON backup/import) — no user action, no migration UI.
- Every constant, palette, and reference renamed/reshaped in one pass: `BC_LABEL`,
  `BC_LBL`, `BC_HEX`, `BC_PALETTES` (all 8 variants), `COND_RUL`, `BCC`, `BSI_COND`,
  plus ~26 call sites (iteration arrays, the BC4/BC5 "needs attention" compound
  check, condition tables/legends) and ~20 unrelated sites that reused BC5/BC6 as
  "the orange/red color" for FCI bands or priority coloring — all shifted down one
  slot for consistency, even though those aren't item-condition reads.
- Docs → Methodology §17 rewritten to the 5-point table; the old bridge note
  flagging the divergence is removed since the app is now aligned.

### 1.2 Likelihood / Consequence of Failure: rename + define
**Now:** two generic 3-tier pills, `Impact` and `Risk` (`IMPACT_OPTS`/`RISK_OPTS`,
both just High/Med/Low with no definitions attached).
**Methodology §5–6:** the same High/Med/Low structure, but named **Likelihood of
Failure (LoF)** and **Consequence of Failure (CoF)**, each with a specific field
definition assessors are meant to apply consistently (§5/§6 tables).
**Gap:** the 3-tier scale already matches — this is a naming and definition gap,
not a data-model gap. Low risk, worth doing early because §10 (Overall Deficiency
Score) and §14 (consistency rules) both talk about LoF/CoF by name, and an assessor
reading Docs → Methodology today won't find those terms anywhere in the actual form.
**Recommended change:**
- Rename `impact`→`cof`, `risk`→`lof` in the data model (or keep the field names and
  just relabel the UI — cheaper, but leaves the JSON export mismatched with the
  Methodology's vocabulary; prefer the real rename if a backup-format version bump
  is acceptable).
- Relabel the pills "Consequence of Failure (CoF)" / "Likelihood of Failure (LoF)"
  in `DetailPanel`, and surface the §5/§6 definition text as inline help (the `?`
  affordance pattern already used elsewhere) instead of duplicating it into the form.

### 1.3 Priority: split near-term triage from long-range/admin categories
**Now:** one 7-value field doing three jobs at once — near-term triage (P1–P3),
a long-range band (P4 "Recommended 6–10yr", P5 "Legacy 11–20yr"), and two
non-condition categories (P6 "New Construction", P7 "ADA").
**Methodology §9:** Priority is **only** the near-term corrective-action timing —
3 tiers, ~1/~2/~3-5 years, explicitly a planning recommendation. Renewal beyond
that horizon is driven by lifecycle data (§11), not a priority value.
**Gap:** this is the largest structural mismatch in the framework. P1–P3 already
match the Methodology almost verbatim (compare the label strings — they're nearly
identical), so nothing breaks today. The problem is P4–P7: they don't correspond to
anything in the Methodology's model and currently get treated as "priority" in every
rollup (`_priShort`, capital-plan priority charts, `PRI_HEX`), which will skew a
Priority-based Overall Deficiency Score (1.4) the moment that ships.
**Recommended change:**
- Keep P1–P3 as `priority`, unchanged.
- Move P6 (New Construction) and P7 (ADA) out of `priority` into a separate
  multi-select `flags` field on the item (a component can be both "new
  construction" and "priority 2," which the current single-select can't express
  anyway).
- Move P4/P5 (6–10yr / 11–20yr) out of `priority` entirely — they're lifecycle
  horizon, not corrective-action urgency. They should fall out of the RUL math in
  1.5 instead of being hand-assigned.
- This is a breaking schema change for every stored item's `priority` field —
  needs a migration pass and every `priority`-reading call site audited
  (`_priShort`, `PRI_HEX`, `priCls`, the Capital Plan priority donut, `rptProjectsByPriority`).

### 1.4 Overall Deficiency Score (new)
**Now:** doesn't exist. FCI exists, but only as a building/portfolio roll-up —
there's no per-item score.
**Methodology §10:** a per-deficiency score from **Condition + CoF + Priority**
(explicitly *not* LoF, to avoid double-counting against Condition), rolled into
qualitative bands — Critical / Very High / High / Moderate / Low / Minimal.
**Gap:** straightforward new feature once 1.1–1.3 land, since it's built entirely
from fields that will already exist in their Methodology-aligned form.
**Recommended change:**
- Add a pure function (`overallDeficiencyScore(item)`) — no stored field, compute
  on read like `fciRating()` already does, so it never goes stale against the
  inputs.
- The Methodology explicitly leaves weights/thresholds unset ("intentionally not
  prescribed... established as the FCA Pro baseline is finalized") — don't invent
  numbers. Flag this as a decision to get from Pete/AEFCA before writing the
  formula, not something to guess at in code.
- Surface it as a new condition-style badge (parallel to the BC badge) on the
  assessment sheet and in item tables once the formula exists.

## Tier 2 — Data depth

### 2.1 Mission / Function at Risk: category list
**Now:** `MISSION_OPTS` — 9 values (Classroom, Admin, Education, Research, Animal
Care, Residential, Public Image, General/Other Services, None).
**Methodology §7:** 10 values — Education/Instruction, Research/Laboratory,
**Clinical/Patient Care**, Animal Care/Research, **Public Safety/Emergency
Response**, Residential/Housing, **Food Service**, **Data/IT**, Administration,
General Facility Operations.
**Gap:** missing Clinical/Patient Care, Public Safety, Food Service, Data/IT —
real gaps for a hospital or mixed-use campus. "Public Image" in the current list
isn't a mission category in the Methodology at all; it's already a BQI criterion
(Docs → Methodology §21.1) and shouldn't also live here.
**Recommended change:** replace `MISSION_OPTS` with the Methodology §7 list
verbatim (it's explicitly meant to be client-configurable — this becomes the
shipped default, not a hardcoded final list). Drop "Public Image" from this field.

### 2.2 Lifecycle: track RUL as a chain, not one number
**Now:** `install_year` + `life_cycle_years` — one editable number, filled from
the catalog's `lc`/`elc` on pick, then just... an item field. No record of
whether it's the catalog default or an assessor override.
**Methodology §11:** an explicit 5-step chain — Original In-Service Year →
Revised In-Service Year → Catalog EUL → Calculated RUL → **Assessor-Adjusted
RUL** — each one traceable, with the override distinguishable from the default.
**Gap:** the app already has an effective assessor-adjusted RUL (it's just
"edit the field"), but nothing records *that* it was adjusted or *why* — which
is a direct miss against §14's "document the rationale for material overrides."
**Recommended change:**
- Add `catalog_eul` (copied from `lc`/`elc` at pick time, never edited after) and
  `revised_in_service_year` (optional) as new fields alongside the existing
  `install_year`/`life_cycle_years`.
- Compute `calculated_rul` from those, and treat the existing `life_cycle_years`
  field as the assessor-adjusted value *only when it differs from the
  calculated one* — surface that delta in the UI (e.g. a small "adjusted from
  Xyr" caption) so the override is visible without adding a required notes field.

### 2.3 Deficiency Cost vs. Developed Project Cost
**Now:** a Project's cost is purely `Σ(mat_cost + lab_cost)` over its linked items
(`CapitalPlanView`, `ClientReport`, `ProjectsView` all compute it this way — there
is no project-level cost field).
**Whitepaper §4 / Methodology §13:** these are explicitly two different numbers.
Deficiency Cost is the per-item planning cost; Developed Project Cost is that sum
*plus* enabling work, design, commissioning, code compliance, abatement, access,
and other project-specific scope once the project is actually developed.
**Gap:** real — there's currently no way to record that a project costs more than
the sum of its parts, which is the normal case once a project is scoped.
**Recommended change:** add an optional `additional_scope_cost` (or a small
itemized list, if that's worth the UI cost) on the Project record. Keep reporting
both numbers distinctly — "Deficiency Cost" (sum of linked items, unchanged) and
"Developed Project Cost" (deficiency cost + additional scope) — rather than
collapsing them into one total.

## Tier 3 — Presentation

### 3.1 Capital plan horizon bands
**Now:** one uniform 10-year bar chart; year 10+ collapses into a single "beyond"
bucket. No visual distinction in confidence between near and far years.
**Whitepaper §6:** Years 1–5 = detailed plan (refined, stakeholder-reviewed,
higher confidence). Years 6–10 = outlook (order-of-magnitude). Beyond Year 10 =
lifecycle forecast only, not a capital project.
**Recommended change:** once 1.3 lands (P4/P5 removed from `priority`), the
existing 10-year projection chart (`rptProjection`) just needs a visual band —
shade or separate years 1–5 from 6–10, and keep the beyond-10 bucket clearly
labeled as forecast, not planned project. No new data required, this is styling +
one extra CSS class on the bar group.

### 3.2 Catalog code format
**Now:** catalog items carry a flat-ish UNIFORMAT code (`u`, e.g. `"B2020"`) plus
an unrelated numeric `cat` ID (e.g. `968598`).
**Methodology §2:** a concatenated Level 5 ID (`D30231803070`) that encodes the
full Major Group → Group Element → Individual Element → Detailed Element →
Asset path in one string.
**Gap:** low priority — this only matters if portfolio roll-ups ever need to
group by intermediate UNIFORMAT levels (Level 3 system reporting, say) rather
than by the flat `disc`/`sheet` grouping the app uses today. Don't touch the
~2,900-item catalog for this without a concrete roll-up need driving it.

## Tier 4 — Platform (Whitepaper-driven, not Methodology)

- **CSV/ODT export.** Whitepaper §9 lists spreadsheet, CSV, ODT, and PDF as
  supported export formats. Today: JSON backup and browser-print PDF only. Add a
  CSV export off the existing item/project tables before touching ODT — CSV
  covers the "get it into Excel" case that's actually being asked for.
- **CMMS/IWMS/EAM/GIS integration.** Whitepaper §9/§11 describes this as
  established per-client, not a built-in feature — no code action now, just
  flagging that any future integration work should export through the CSV path
  above rather than a bespoke format per system.

## Suggested sequencing

1. **1.2** (LoF/CoF rename) — done.
2. **1.1** (condition scale) — done.
3. **1.3** (priority split) — next up; the 1.1 migration pattern (automatic shift +
   `_bc_migrated`-style breadcrumb for the ambiguous case) is the template to reuse.
4. **1.4** (Overall Deficiency Score) — needs a weights/thresholds decision from
   Pete first; code is quick once that's answered.
5. **2.1–2.3** — independent of each other and of Tier 1, can slot in anytime.
6. **3.1–3.2, Tier 4** — whenever, none of this blocks or is blocked by anything else.
