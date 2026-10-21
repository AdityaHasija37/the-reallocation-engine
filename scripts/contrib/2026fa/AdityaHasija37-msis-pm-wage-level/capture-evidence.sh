#!/usr/bin/env bash
# Regenerate every evidence capture for the worked run, from the repo root:
#   bash scripts/contrib/2026fa/AdityaHasija37-msis-pm-wage-level/capture-evidence.sh
# Each file in runs/ holds: the verbatim command, a UTC timestamp, the full output, the exit code.
# Break attempts that need a modified copy (mutant, tampered extract, forged pin) run in a temp
# dir; the real fixtures and data are never edited. Needs network for ats:liveness and the fetch.
set -uo pipefail
cd "$(dirname "$0")/../../../.."
C=scripts/contrib/2026fa/AdityaHasija37-msis-pm-wage-level
ROOT=$(pwd)
R=$ROOT/course/2026fa/submissions/AdityaHasija37/mode-build/runs
T=$(mktemp -d)
RUN_DATE=2026-10-21
mkdir -p "$R"

cap() {  # cap <file> <command string>
  local f="$R/$1"; shift
  { echo "\$ $*"; echo "# run at $(date -u +%Y-%m-%dT%H:%M:%SZ)"; (cd "$ROOT" && eval "$*") 2>&1; echo "# exit $?"; } > "$f"
  echo "captured ${f#$ROOT/} ($(tail -1 "$f"))"
}

# Scratch inputs for break attempts (clearly not gate clearances)
echo '{"regime_in_force":null,"checked_on":null,"checked_by":null,"how":null}' > "$T/rule-open.json"
echo "{\"regime_in_force\":\"current-2005\",\"checked_on\":\"$RUN_DATE\",\"checked_by\":\"BREAK-TEST (not a gate clearance)\",\"how\":\"break harness\"}" > "$T/rule-break.json"
sed "s/$RUN_DATE/2026-11-19/" "$T/rule-break.json" > "$T/rule-break-1119.json"
sed 's/current-2005/proposed-2026-nprm/' "$T/rule-break.json" > "$T/rule-proposed.json"
python3 - "$C" "$T" <<'EOF'
import json, sys
C, T = sys.argv[1], sys.argv[2]
base = json.load(open(f"{C}/fixtures/scenarios.2026-10-21.json"))
def save(name, fn):
    s = json.loads(json.dumps(base)); fn(s); json.dump(s, open(f"{T}/{name}", "w"))
def s1_only(s): s["scenarios"] = [x for x in s["scenarios"] if x["id"] == "S1"]
def relabel(confirmer):
    def f(s):
        s1_only(s); s["scenarios"][0]["pay"]["basis"] = "base"; s["scenarios"][0]["pay"]["basis_confirmed_by"] = confirmer
    return f
save("s1-relabel-noconfirm.json", relabel(None))
save("s1-relabel-falseconfirm.json", relabel("BREAK-TEST false confirmation"))
save("soc-unsigned.json", lambda s: s["soc_candidates"].update(set_by=None))
save("soc-unknown.json", lambda s: s["soc_candidates"]["codes"].append("99-9999"))
EOF
mkdir -p "$T/mut" "$T/tamper" "$T/fetch"
cp $C/*.py "$T/mut/"; cp -r $C/data $C/fixtures "$T/mut/"
sed -i.bak 's/if salary >= levels\[lv\]:/if salary > levels[lv]:/' "$T/mut/wage_level.py"
cp -r $C/data "$T/tamper/"; sed -i.bak 's/,53.07,68.48,/,53.07,58.48,/' "$T/tamper/data/oflc-2026-27-pm-extract.csv"
cp $C/fetch-oflc.sh "$T/fetch/"; echo "OFLC_Wages_2026-27.zip 0000000000000000000000000000000000000000000000000000000000000000" > "$T/fetch/checksums.lock"

# ── Data
cap 01-fetch-oflc.sh.txt "bash $C/fetch-oflc.sh 2026-27 2>&1 | grep -v '%'"
cap 02-extract.txt "python3 $C/wage_level.py extract && git diff --stat -- $C/data/"
# ── Gate L (repo script, unchanged). Files 03–05 are cited as evidence by the scenarios.
cap 03-liveness-S1-verkada.txt "npm run ats:liveness -- https://job-boards.greenhouse.io/verkada/jobs/5173135007"
cap 04-liveness-S2-flexport.txt "npm run ats:liveness -- https://job-boards.greenhouse.io/flexport/jobs/8158023"
cap 05-liveness-S3-asana.txt "npm run ats:liveness -- 'https://www.asana.com/jobs/apply/8180874?gh_jid=8180874'"
# ── The run, tests, independent checks
cap 10-mode-run.txt "python3 $C/wage_level.py run --run-date $RUN_DATE"
cap 11-tests-py313.txt "python3 $C/test_wage_level.py"
cap 12-tests-py312.txt "python3.12 $C/test_wage_level.py"
cap 13-xcheck-raw-oflc-and-80days.txt "python3 $C/xcheck_raw.py $C"
cap 14-sensitivity-vintage.txt "python3 $C/sensitivity_vintage.py"
cap 15-determinism.txt "shasum -a 256 $C/out/run-log.json $C/out/report.md > $T/h1 && python3 $C/wage_level.py run --run-date $RUN_DATE >/dev/null && shasum -a 256 $C/out/run-log.json $C/out/report.md > $T/h2 && cat $T/h1 && diff $T/h1 $T/h2 && echo identical"
cap 16-json-parse.txt "python3 -c \"import json; d=json.load(open('$C/out/run-log.json')); print('summary', d['summary']); print('routes', {s['id']: s['route'] for s in d['scenarios']}); print('probabilities', [s['selection_probability'] for s in d['scenarios']])\""
cap 17-clean-clone.txt "git clone -q --branch mode/AdityaHasija37-msis-pm-wage-level https://github.com/AdityaHasija37/the-reallocation-engine.git $T/clone && cd $T/clone && git log --oneline -1 && test ! -e $C/raw && python3 $C/wage_level.py run --run-date $RUN_DATE && python3 $C/test_wage_level.py 2>&1 | grep -E '^(Ran|OK|FAILED)' && shasum -a 256 $C/out/run-log.json $C/out/report.md && git status --short | wc -l"
# ── Break attempts
cap 20-BREAK-liveness-fake-id.txt "npm run ats:liveness -- https://job-boards.greenhouse.io/flexport/jobs/9999999999"
cap 21-liveness-recheck-earlier-uncertain-posting.txt "npm run ats:liveness -- https://jobs.lever.co/payjoy/4fb8781e-413f-487c-a0a0-23466ed3c834"
cap 22-BREAK-gate-R-open.txt "python3 $C/wage_level.py run --run-date $RUN_DATE --rule-check $T/rule-open.json --out $T/o22; echo \"(wage_level.py exit \$?)\"; test -e $T/o22 && echo 'OUTPUT WRITTEN' || echo 'nothing written'"
cap 23-BREAK-gate-R-stale.txt "python3 $C/wage_level.py run --run-date 2026-12-01 --rule-check $T/rule-break.json --out $T/o23; echo \"(wage_level.py exit \$?)\"; test -e $T/o23 && echo 'OUTPUT WRITTEN' || echo 'nothing written'"
cap 24-BREAK-gate-R-proposed-regime.txt "python3 $C/wage_level.py run --run-date $RUN_DATE --rule-check $T/rule-proposed.json --out $T/o24; echo \"(wage_level.py exit \$?)\"; test -e $T/o24 && echo 'OUTPUT WRITTEN' || echo 'nothing written'"
cap 25-BREAK-gate-L-stale-liveness.txt "python3 $C/wage_level.py run --run-date 2026-11-19 --rule-check $T/rule-break-1119.json --out $T/o25; echo \"(wage_level.py exit \$?)\"; grep 'Stopped' $T/o25/report.md"
cap 26-BREAK-gate-S-unsigned.txt "python3 $C/wage_level.py run --run-date $RUN_DATE --rule-check $T/rule-break.json --scenarios $T/soc-unsigned.json --out $T/o26; echo \"(wage_level.py exit \$?)\"; test -e $T/o26 && echo 'OUTPUT WRITTEN' || echo 'nothing written'"
cap 27-BREAK-gate-S-unknown-code.txt "python3 $C/wage_level.py run --run-date $RUN_DATE --rule-check $T/rule-break.json --scenarios $T/soc-unknown.json --out $T/o27; echo \"(wage_level.py exit \$?)\"; test -e $T/o27 && echo 'OUTPUT WRITTEN' || echo 'nothing written'"
cap 28-BREAK-gate-P-ote-relabel-unconfirmed.txt "python3 $C/wage_level.py run --run-date $RUN_DATE --rule-check $T/rule-break.json --scenarios $T/s1-relabel-noconfirm.json --out $T/o28; echo \"(wage_level.py exit \$?)\"; grep 'Stopped' $T/o28/report.md"
cap 29-BREAK-gate-P-ote-relabel-FALSE-confirm.txt "python3 $C/wage_level.py run --run-date $RUN_DATE --rule-check $T/rule-break.json --scenarios $T/s1-relabel-falseconfirm.json --out $T/o29; echo \"(wage_level.py exit \$?)\"; grep -E '^\| (11-3021|15-1211)' $T/o29/report.md"
cap 30-BREAK-mutant-strict-inequality.txt "cd $T/mut && python3 -m unittest -v test_wage_level.Levels.test_boundaries_exactly_equal_meets_level"
cap 31-BREAK-tampered-extract.txt "python3 $C/wage_level.py run --run-date $RUN_DATE --rule-check $T/rule-break.json --extract $T/tamper/data/oflc-2026-27-pm-extract.csv --out $T/o31; echo \"(wage_level.py exit \$?)\"; test -e $T/o31 && echo 'OUTPUT WRITTEN' || echo 'nothing written'"
cap 32-BREAK-missing-input.txt "python3 $C/wage_level.py run --run-date $RUN_DATE --rule-check $T/rule-break.json --national $T/nope.xlsx --out $T/o32; echo \"(wage_level.py exit \$?)\"; test -e $T/o32 && echo 'OUTPUT WRITTEN' || echo 'nothing written'"
cap 33-BREAK-fetch-forged-checksum.txt "bash $T/fetch/fetch-oflc.sh 2026-27 2>&1 | grep -v '%'; echo \"(fetch-oflc.sh exit \${PIPESTATUS[0]})\"; test -e $T/fetch/raw && echo 'RAW WRITTEN' || echo 'nothing written'"
# ── Repo conformance after the change
cap 40-verify.txt "npm run verify"
cap 41-doctor.txt "npm run doctor"
cap 42-pii-scan-branch-diff.txt "node scripts/pii-scan.mjs --diff upstream/main"
rm -rf "$T"
