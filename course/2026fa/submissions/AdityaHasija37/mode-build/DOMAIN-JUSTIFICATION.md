# Domain justification — msis-pm-wage-level

## Executive summary

**What this is.** One page on who this mode is for, what they cannot see without it, and
the two mistakes it is built to catch.

**What it decides.** Since 2026 the H-1B lottery weights each registration by wage level.
A product-management job seeker cannot see which level a posted salary reaches, because
the employer's choice of job code decides it. On real postings, the same salary earned
anywhere from 1 to 4 lottery entries depending on that choice.

## Who uses it, and when

I'm an international MS Information Systems student (STEM-designated), graduating in
December 2026. I have about 3.5 years of prior work experience and I'm targeting product
manager, AI product manager and product analyst roles in the San Francisco Bay Area and
Seattle. OPT plus the 24-month STEM extension gives me roughly three H-1B registration
seasons: March 2027, 2028 and 2029. I use the mode at two moments. The first is before
a final round at a company whose posting shows a pay range. The second is when an offer
arrives, because by then the worksite and base salary are fixed and only the job code is
still open.

## The information asymmetry

The weighted-selection rule (in effect from February 27, 2026) gives a registration
1, 2, 3 or 4 entries according to the highest Department of Labor wage level the
offered wage meets. That level is set by three things:

1. **the SOC code the employer files.** The employer chooses it, and the applicant never sees it on a posting;
2. **the worksite's wage area**, which has its own Level I–IV table;
3. **the base wage.**

Product managers have **no SOC code of their own**. A PM title can plausibly be filed as
a marketing manager, an IS manager, a management analyst, a systems analyst, "computer
occupations, all other", or a data scientist (for AI and analytics PMs). The level tables
for those codes are far apart. In San Francisco, Level I runs from **$73,258** (management
analyst) to **$167,565** (IS manager). So at Flexport's posted Senior PM midpoint
($193,500, base, live on 2026-10-21) the official table gives **1 entry** under the IS
manager code and **4 entries** under the management analyst code. Same job, same salary,
four times the weight, and nothing on the posting tells the applicant which one
applies. The employer's immigration counsel knows. The student doesn't, unless they ask,
and they only know to ask if they've seen this table.

## Engine layers it connects

- **Cognitive Pivot (BLS / O\*NET).** The mode runs on OEWS wage distributions by SOC,
  through the official OFLC area tables and the repo's national OEWS file, and shows each
  code's Cognitive Pivot score. That puts a question the Cognitive Pivot thesis cares about
  next to the lottery math: is the employer filing a judgment-heavy role under a
  routine-analysis code?
- **80 Days to Stay.** It uses the employer's H-1B approval record and company-wide median
  sponsored salary as context, and it gates on the visa timeline (lottery seasons left
  before STEM OPT ends).
- **Job-Ops.** Posting liveness (`ats:liveness`) is a hard gate before anything is levelled.

## Failure modes specific to this domain

**1. The national-median shortcut overstates the level in high-wage metros.** A careful
student, or an LLM answering from general knowledge, looks up BLS national percentiles,
sees that $174,000 is above the national 75th percentile for data scientists, and
concludes "Level IV, 4 entries". The official San Francisco table says **Level II**. In
this run the national shortcut disagreed with the official city level in **23 of 54**
comparisons, and **all 23 overstated** the level. None understated it. The error always
points the same way, toward false confidence. That makes it hardest to catch for the
diligent student who *did* check government data, because using BLS feels like
verification. It's also hard for a student who moves between metros: the same national
number is "right" in a lower-wage area and wrong in SF or Seattle.

**2. A pay-transparency range is not the offered wage.** California and Washington
require posted pay ranges, and students treat them as the salary. But some ranges are
**on-target earnings** (base plus commission). Verkada's "Business Systems – Product
Manager" posting says so in so many words. The wage level is judged on base pay. Read as
base, Verkada's $160,000 low end looks like Level III or IV under the systems-analyst
code; the real base is lower by an amount the posting doesn't state. This is hardest to
catch for students whose previous job markets quote total "cost to company" as a single
number, and for PM roles that sit next to sales (solutions, partner, commerce), where
OTE wording is common. The mode refuses to level any range a person has not confirmed
is base salary. Its honest limit is that it cannot catch a person who confirms falsely.
