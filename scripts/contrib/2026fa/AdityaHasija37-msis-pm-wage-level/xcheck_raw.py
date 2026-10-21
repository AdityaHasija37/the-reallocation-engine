#!/usr/bin/env python3
"""Independent cross-check (needs raw/ from fetch-oflc.sh): usage: xcheck_raw.py <this dir>"""
# Independent cross-check: recompute levels from the RAW OFLC ALC_Export.csv (not the extract)
# and compare to every leveled row in out/run-log.json. Also cross-check 80 Days counts.
import csv, json, sys
C = sys.argv[1]
raw = {(r["Area"], r["SocCode"]): r for r in csv.DictReader(open(f"{C}/raw/2026-27/ALC_Export.csv"))}
log = json.load(open(f"{C}/out/run-log.json"))
checked = mism = 0
for s in log["scenarios"]:
    for row in s["rows"]:
        r = raw[(s["worksite"]["oflc_area"], row["soc"])]
        lv = [float(r[f"Level{i}"]) * 2080 for i in range(1, 5)]
        exp = "below-I"
        for name, v in zip(["I", "II", "III", "IV"], lv):
            if row["salary"] >= v: exp = name
        checked += 1
        if exp != row["level"]:
            mism += 1; print("MISMATCH", s["id"], row["soc"], row["offer_point"], exp, row["level"])
print(f"raw-OFLC recompute: {checked} rows checked, {mism} mismatches")
eighty = {r["company_name"]: r for r in csv.DictReader(open("data/80-days-to-stay/80-days-csv/mapped_student_employment_targets_v3.csv", encoding="utf-8", errors="replace"))}
names = {x["id"]: x["company_80days"] for x in json.load(open(f"{C}/fixtures/scenarios.2026-10-21.json"))["scenarios"]}
for s in log["scenarios"]:
    sp = s["sponsorship_80days"]; r = eighty[names[s["id"]]]
    print(f"80 Days {s['id']}: CSV approvals={r['Total Approvals']} denials={r['Total Denials']} → log {sp['approvals']}/{sp['denials']}")
probs = [s["selection_probability"] for s in log["scenarios"]]
print("selection_probability values:", probs)
print("summary:", json.dumps(log["summary"]))
