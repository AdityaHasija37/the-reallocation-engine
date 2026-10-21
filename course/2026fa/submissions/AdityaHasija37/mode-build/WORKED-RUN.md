# Worked run — msis-pm-wage-level v0.1.0, 2026-10-21

## Executive summary

**What this is.** The record of one real run of the wage-level mode. It used four live
product-manager postings with posted pay ranges in San Francisco and Seattle, and the
Labor Department's official 2026–27 wage tables. Every command is pasted with its real
output, followed by what was verified versus judged, how the output was checked, twelve
deliberate attempts to break it, and what the mode still gets wrong.

**What it found.** Of the four posting-and-city combinations, three were levelled. One
(Verkada) was refused, because its posted range includes commission. For each levelled
posting, the number of lottery entries at the same salary ranged from 1 to 4 depending
on the job code the employer files. National pay data put the level too high in 23 of
54 comparisons and never too low. Every level was recomputed independently from the raw
government file, with zero mismatches.

**What broke.** The break attempts found three real defects: a hand-edited data file
was used without complaint, a missing file crashed instead of stopping cleanly, and paths
outside the repository crashed the log writer. All three are fixed and covered by tests.
One weakness can't be fixed in code: a person who falsely confirms a pay range as base
salary gets a wrong level.

---

## Inputs

| Input | Value | Label |
|---|---|---|
| Persona | MS Information Systems (STEM), graduating Dec 2026, ~3.5 yrs experience, PM / AI PM / Product Analyst, SF Bay + Seattle; OPT start **2027-01-15 (assumed)** | your-input; no private data used |
| Postings | Verkada *Business Systems – Product Manager* (San Mateo); Flexport *Senior Product Manager, Commerce* (Bellevue **and** San Francisco → two scenarios); Asana *Senior Product Manager, AI Studio* (San Francisco) | record (public Greenhouse API, captured 2026-10-21) |
| Pay sentences | quoted verbatim in `fixtures/scenarios.2026-10-21.json` | record |
| Official wage levels | OFLC wage year 2026-27 (`OFLC_Wages_2026-27.zip`, sha256 `edc01f64…f08f`) → 24-row extract (3 metros × 8 SOC), sha256 `ce8e3eda…115a` | record |
| National percentiles | `data/bls/oesm24nat/national_M2024_dl.xlsx` (May 2024) | record, used as proxy only |
| Sponsorship | 80 Days CSV (`mapped_student_employment_targets_v3.csv`) | record |
| Gate P (pay basis), Gate S (SOC set), Gate R (rule in force) | cleared by **Aditya Hasija (AdityaHasija37)**, 2026-10-21 | your-input |

How the postings were chosen: I filtered the 80 Days CSV to companies in SF Bay or
Seattle with ≥ 3 approvals and a product title in `top_job_titles_sponsored` (63
companies). Then I read 13 of their Greenhouse boards for PM titles in those metros
with a pay range in the text. That selection used a scratch script, which is not
committed (the `capture-scenario` TODO in the recipe). I picked three postings for
contrast: OTE wording (Verkada), one range across two metros (Flexport), and an AI PM
at the top of the market (Asana).

## Commands and real output

All commands were run from the repo root. Each file under `runs/` holds the command,
a UTC timestamp, the full output and the exit code.

### 0. Baseline (before any change) — `runs/01`, `runs/02`

```
$ npm run verify
conformance: … ✓ all conform (machine half of P4). Adequacy is still the human gate.
WARN (3):
  W1 ignore path not in .gitignore: archive/
  W2 private path not gitignored (PII/secret risk): private/
  W2 private path not gitignored (PII/secret risk): data/ats/
✓ manifest check passed (3 warnings)
# exit 0
$ npm run doctor
  ✓ no private/PII paths are tracked
  environment: ✓ runnable
# exit 0
```

### 1. Data — pinned fetch, then extract

```
$ bash scripts/contrib/2026fa/AdityaHasija37-msis-pm-wage-level/fetch-oflc.sh 2026-27
fetching https://flag.dol.gov/sites/default/files/wages/OFLC_Wages_2026-27.zip
checksum OK (edc01f64e2f805efe577337935e5c664adbd93d3135750aff8015fefe805f08f)
→ raw/2026-27
$ python3 scripts/contrib/2026fa/AdityaHasija37-msis-pm-wage-level/wage_level.py extract
wrote …/data/oflc-2026-27-pm-extract.csv (24 rows; missing pairs: 0)
```

(The checksum was pinned from an earlier manual download the same day. The fetcher's
own independent download reproduced it exactly.)

### 2. Gate L — liveness (repo script, unchanged) — `runs/03`–`05`

```
$ npm run ats:liveness -- https://job-boards.greenhouse.io/verkada/jobs/5173135007
✅ active     https://job-boards.greenhouse.io/verkada/jobs/5173135007
Results: 1 active  0 expired  0 uncertain
# exit 0
$ npm run ats:liveness -- https://job-boards.greenhouse.io/flexport/jobs/8158023
✅ active     https://job-boards.greenhouse.io/flexport/jobs/8158023
Results: 1 active  0 expired  0 uncertain
# exit 0
$ npm run ats:liveness -- https://www.asana.com/jobs/apply/8180874?gh_jid=8180874
✅ active     https://www.asana.com/jobs/apply/8180874?gh_jid=8180874
Results: 1 active  0 expired  0 uncertain
# exit 0
```

### 3. The run — `runs/20`

```
$ python3 scripts/contrib/2026fa/AdityaHasija37-msis-pm-wage-level/wage_level.py run --run-date 2026-10-21
wrote …/out/run-log.json and …/out/report.md
scenarios 4 → leveled 3 · stopped 1 (stop-pay-basis 1); rows 54 · refused 0 · below-I 0 · proxy disagrees 23/54 (overstates 23, understates 0)
# exit 0
```

Report excerpt (`out/report.md`, verbatim), the San Francisco scenario:

```
## S2b · Flexport — Senior Product Manager, Commerce
| SOC (employer's choice) | OFLC Level I / II / III / IV (annual) | Low | Mid | High | Entries L/M/H | Mid: to next level | National proxy (now · proposed) | Cognitive Pivot |
| 11-2021 Marketing Managers | $148,387 / $191,942 / $235,477 / $279,032 | I | II | II | 1/2/2 | +$41,977 → III | III–IV · I–III ⚠ disagrees | 3.974 |
| 11-3021 Computer and Information Systems Managers | $167,565 / $208,104 / $248,643 / $289,182 | I | I | II | 1/1/2 | +$14,604 → II | III–IV · I–III ⚠ disagrees | 3.834 |
| 13-1111 Management Analysts | $73,258 / $105,165 / $137,093 / $169,000 | IV | IV | IV | 4/4/4 | at top level | IV · IV | 4.013 |
| 15-1211 Computer Systems Analysts | $95,930 / $120,536 / $145,163 / $169,770 | IV | IV | IV | 4/4/4 | at top level | IV · IV | 4.024 |
| 15-1299 Computer Occupations, All Other | $80,870 / $121,014 / $161,138 / $201,282 | III | III | IV | 3/3/4 | +$7,782 → IV | IV · IV ⚠ disagrees | — |
| 15-2051 Data Scientists | $110,386 / $142,438 / $174,512 / $206,565 | II | III | IV | 2/3/4 | +$13,065 → IV | IV · III–IV ⚠ disagrees | — |
Spread across SOC codes (entries): low 1–4 · mid 1–4 · high 2–4
```

The same posting in Bellevue (S2a) at the same $193,500 midpoint gives 2 entries under
11-3021 (Seattle's Level II is $188,718), compared with 1 in San Francisco. So the city
moves the result as well as the code. Verkada (S1) was stopped:

```
**Stopped — stop-pay-basis.** posted range is 'ote', not base salary; the wage level is judged on base wage, so this range cannot be leveled — ask for the base component. No level is shown.
```

### 4. Tests — `runs/21`

```
$ python3 scripts/contrib/2026fa/AdityaHasija37-msis-pm-wage-level/test_wage_level.py
…
Ran 26 tests in 0.284s
OK
# exit 0
```

### 5. Conformance after the change — `runs/24`–`27`

```
$ npm run verify      → ✓ all conform … ✓ manifest check passed (3 warnings)   # exit 0
$ npm run doctor      → ✓ no private/PII paths are tracked · environment: ✓ runnable   # exit 0
$ npm run pii-scan    → pii-scan: 1 finding(s) … [email] package-lock.json — <npm author email, redacted>   # exit 1
$ node scripts/pii-scan.mjs --diff upstream/main → pii-scan: clean ✓   # exit 0
```

The one `pii-scan` finding is the npm author email in upstream's `package-lock.json`.
It is unchanged by this branch, and the scan of this branch's diff is clean.

## Verified vs. inferred, line by line

| Claim in the report | Established by | Kind |
|---|---|---|
| The four postings were live on 2026-10-21 | `ats:liveness` → `active`, exit 0 | **verified** (record) |
| Pay sentences and ranges | Greenhouse API text, quoted verbatim | **verified** (record) |
| Verkada's range includes commission; Flexport's and Asana's are base | the quoted wording, read by a person (Gate P) | **judged** (your-input) |
| Level I–IV annual wages per metro × SOC | OFLC file, hourly × 2080; 54/54 recomputed from the raw file | **verified** (record + arithmetic) |
| Level met, entries, gap to next level | comparison against those wages; boundary tests | **verified** (derived) |
| "Midpoint" offer | (low + high) / 2 | **derived**, not an offer |
| Which SOC codes are plausible for a PM | my list (Gate S) | **judged** (your-input), the largest judgment |
| Which SOC the employer will file | — | **not known** |
| National bracket under the current and proposed rules | May 2024 national percentiles × approximate level percentiles | **proxy**, never decides |
| "National data overstates the level 23/54 times" | counted by the script from the rows above | **verified** (derived), for these 3 postings only |
| Rule in force = current (2005) | Federal Register + DOL news, checked by a person | **judged** (your-input, Gate R) |
| 3 lottery seasons left | OPT start (assumed) + 36 months; March registration assumed | **inferred** from an assumption |
| Sponsorship counts and median salary | 80 Days CSV; cross-checked | **verified** (record) |
| Cognitive Pivot scores | repo compact extract; blank for 15-2051 / 15-1299 | **verified** (record), context only |
| Selection probability | — | **refused**; no data |
| Any LLM judgment in a value | none | — |

## Verification — how I know the output is real

1. **Independent recompute from the raw government file** (`runs/22`). A separate
   script reads `raw/2026-27/ALC_Export.csv` directly, not the extract, and recomputes
   every level.
   ```
   raw-OFLC recompute: 54 rows checked, 0 mismatches
   80 Days S1: CSV approvals=272.0 denials=4.0 → log 272/4
   80 Days S2a: CSV approvals=312.0 denials=6.0 → log 312/6
   80 Days S3: CSV approvals=352.0 denials=14.0 → log 352/14
   selection_probability values: [None, None, None, None]
   ```
2. **Hand check of one cell.** Raw row `"41860","15-2051",1,"53.07","68.48","83.90","99.31"`
   gives Level II = 68.48 × 2080 = **$142,438.40**, and the report shows **$142,438**.
   At $174,000, $174,000 ≥ $142,438 and $174,000 < $174,512 (83.90 × 2080), so the level
   is **II**. The report's S2b low column for 15-2051 says **II**.
3. **Parsed the JSON.** `run-log.json` loads; `summary` matches the console line; every
   `selection_probability` is `null`.
4. **Determinism** (`runs/23`). I ran the mode twice and hashed both outputs; they are
   identical.
5. **Provenance chain.** The zip's sha256 is pinned in `checksums.lock`, the extract's
   sha256 is in its provenance file, the run refuses a mismatch, and the run log records
   the verified hash.
6. **Deliberate break attempts.** See the attestation below.

## Attestation

- Recipe: msis-pm-wage-level v0.1.0 (`recipes/cases/2026fa/AdityaHasija37-msis-pm-wage-level.md`)
- By: Aditya Hasija (AdityaHasija37) · 2026-10-21. Commands executed by Claude Code at my
  direction; gates P, S and R cleared by me.

### Tested

| Ran | Saw | Expected |
|---|---|---|
| `npm run ats:liveness` on the 3 postings (`runs/03`–`05`) | `active` ×3, exit 0 | active |
| `wage_level.py run --run-date 2026-10-21` (`runs/20`) | 4 scenarios → 3 leveled, 1 `stop-pay-basis`; 54 rows; exit 0 | OTE range refused, others leveled |
| `test_wage_level.py` (`runs/21`) | 26/26 OK | all pass |
| Recompute from raw `ALC_Export.csv` (`runs/22`) | 54 rows, 0 mismatches; 80 Days counts equal | 0 mismatches |
| Run twice, hash outputs (`runs/23`) | identical | identical |
| Fresh `git clone` of this branch (no `raw/`, no network) → `run` + tests | 26/26 OK; `run-log.json` sha256 `b57b668f…`, `report.md` `0eea9aad…`, identical to the committed outputs; `git status` clean | reproducible from the repo alone |
| `npm run verify` / `doctor` after the change (`runs/24`, `25`) | exit 0 / exit 0, same 3 warnings as baseline | no new failures |
| `pii-scan --diff upstream/main` (`runs/27`) | clean | clean |
| **Break:** `ats:liveness` on a fake job ID (`runs/06`) | `expired`, redirect to `?error=true`, exit 1 | gate closed |
| **Break:** `ats:liveness` on a posting from 18 days earlier (`runs/07`) | `uncertain` (navigation timeout), exit 1 | treated as closed |
| **Break:** run with Gate R empty (`runs/08`) | `STOP rule-check: 'regime_in_force' missing`, exit 2, no output dir | stop, nothing written |
| **Break:** mutant `>=` → `>` in `level_met` (`runs/09`) | boundary test FAILS ('I' != 'II') | test catches mutant |
| **Break:** relabel Verkada OTE as base, no confirmer (`runs/10`) | `stop-pay-basis` "nobody has confirmed…" | stopped |
| **Break:** relabel Verkada OTE as base **with a false confirmer** (`runs/11`) | **levelled**: 15-1211 Level III–IV, 11-3021 `below-I` at low end | — this cannot be caught in code; see "Did not test" |
| **Break:** rule check 41 days old (`runs/12`) | `STOP … checked 41 days before the run (must be 0–30)`, exit 2 | stop |
| **Break:** regime set to the proposed rule (`runs/13`) | `STOP … a run under a newer rule needs a newer OFLC file`, exit 2 | stop |
| **Break:** edit one wage in the extract, run the hash test (`runs/14`) | test FAILS (sha mismatch) | caught |
| **Break:** forged pin in `checksums.lock` (`runs/15`) | `CHECKSUM MISMATCH … refusing.`, no `raw/` written | refuse |
| **Break:** run on the edited extract (`runs/17` before fix, `runs/18` after) | before: the run computed levels from tampered data (then crashed on a path); after: `STOP input: OFLC extract sha256 … does not match its provenance`, exit 2 | stop |
| **Break:** missing data file (`runs/16` before fix, `runs/19` after) | before: Python traceback, exit 1; after: `STOP input: national file not found`, exit 2 | clean stop |
| End to end on San Jose (OFLC "High Wage" for 11-3021) — test `test_high_wage_row_refused_end_to_end` | rows refused, `level` null | refused, never filled |

### Did not test

- **A dishonest or careless Gate P.** `runs/11` shows a false "base" confirmation gets
  levelled. The mode trusts the named person, and only the record of who confirmed
  stands between a mistake and a wrong level.
- **Whether my SOC candidate list is what these employers actually file.** I have no
  LCA disclosure data (TODO). The spread of 1–4 entries holds *across my list*, not
  across what Flexport or Asana actually do.
- **Any offer.** The low/mid/high points are posted ranges, not offers.
- **The lottery-season count against real dates.** The OPT start is assumed, and USCIS
  sets registration dates each year.
- **The "below-I" path on real data.** No real scenario hit it; it's covered by unit tests
  and by the false-confirmation break run only.
- **The proposed-rule bracket at metro level.** It is national-only (TODO).
- **Hybrid and remote worksites.** Every scenario's worksite was taken from the posting's
  location text.
- **Using the report with an employer.** Gate D itself was cleared: I read `out/report.md`,
  including "What this cannot tell you", on 2026-10-21. No employer conversation has used
  it yet.
- **Python versions** other than 3.13.3 on macOS; CI uses 3.12 (standard library only,
  not run there).
- **`npm run doctor` on the case recipe.** `doctor` reads only top-level `recipes/`; I
  checked the 6/6 TODO count by hand.

### Broke during testing, fixed

- **A tampered extract was levelled silently.** `run` recorded the extract hash but never
  compared it. Fix: `check_inputs()` in `wage_level.py` compares the hash with the
  provenance file and stops with exit 2; regression test `test_tampered_extract_stops_the_run`.
- **A missing data file gave a traceback (exit 1)**, not the documented clean stop
  (exit 2). Fix: an existence check in `check_inputs()`; test `test_missing_input_is_a_clean_stop`.
- **Inputs outside the repo crashed the log writer** (`Path.relative_to`). Fix: the
  `rel()` helper falls back to an absolute path.
- **The report summary said "1 were stopped"** and printed a Python dict. Fixed in the
  renderer, then re-ran (`runs/20`–`25` are post-fix).

- **I leaked an upstream email into my own files.** Pasting the full-tree `pii-scan` output
  into this document and `runs/26` copied the npm author email from upstream's
  `package-lock.json`. Then `pii-scan --diff upstream/main` flagged 2 findings, which would
  have failed CI's history scan. Fix: redacted in both files (marked in `runs/26`), and the
  unpushed branch squashed to one commit so the address isn't in its history. The rescan
  was clean.

### Edited after this attestation was first written

Any edit to the recipe voids an attestation, so I'm recording this one. After I cleared
Gate D, the recipe text changed in four ways: a *Purpose* heading and paragraph, a
consolidated *Proposed additions* table, a log-template heading naming `logs/RUN_LOG.md`,
and `last_gate` recording Gate D. No script, fixture or data file changed. I then re-ran
`wage_level.py run --run-date 2026-10-21`: `run-log.json` sha256 `b57b668ffd699472…` and
`report.md` `0eea9aad0e751283…` were identical to before, tests were 26/26 OK, and
`npm run verify` exited 0. The rows above therefore still describe this recipe version.

## Reflection

**What went well.**
- Grounding in the official DOL table removed estimation entirely. The national-data
  shortcut a student would naturally use was wrong 23 times out of 54, always in the
  flattering direction, and the mode now proves that on every run instead of asserting it.
- The OTE refusal came from a real posting, not a contrived fixture.
- The break attempts paid for themselves: three of twelve found real defects.

**What the mode got wrong or missed.**
- **The signal is mostly "analyst code vs manager code".** In both metros the analyst
  codes (13-1111, 15-1211) sit at Level IV for every PM salary I tested, and the manager
  codes sit at Level I–II. The six-row table is really two groups, and the report should
  say so in its summary rather than leave the reader to notice.
- **It can read like advice to pick a code.** An employer has to file the code that
  matches the job's duties. Filing a PM as a "management analyst" to gain entries is a
  compliance question, not a lever. The recipe refuses to recommend codes, but the table
  doesn't say this out loud.
- **The SOC list is my judgment.** Without LCA disclosure data, the 1–4 spread is a
  spread over my list, not evidence of how these employers actually file.
- **Scenario capture is manual.** I selected and transcribed postings with a scratch
  script that isn't committed, which is the weakest link in the provenance chain.
- **Fees and entry rules dominate in practice.** A proposed $103,265 fee on all
  cap-subject petitions, and the extended $100,000 entry payment, may decide whether an
  employer sponsors at all, and no wage table captures that.

**Next steps (concrete).**
1. Ingest one quarter of OFLC LCA disclosure data and build `lca-soc-lookup.py`, so Gate S
   becomes "Flexport filed *Senior Product Manager* under SOC X at Level Y in n LCAs".
2. Add a "duties must match the code" line and an analyst-vs-manager grouping to the
   report summary.
3. Commit `capture-scenario.py` (Greenhouse/Lever/Ashby hosts only), with `basis` always left null.
4. Close the `DEFINE` TODO by reading the amended 8 CFR 214.2(h)(8)(iii) on below-Level-I
   and "High Wage" weighting.
5. Re-run the day the EAD card arrives, with the real OPT start date, and at each offer.
