# Domain justification — msis-pm-wage-level

## Executive summary

**What this is.** One page on who this mode is for, what they cannot see without it, and
the two mistakes it is built to catch. **What it shows:** under the 2026 wage-weighted
H-1B lottery, the same product-manager salary earned 1 to 4 entries depending on a job
code the employer picks and the applicant never sees.

## Who, and when

I'm an international MS Information Systems student (STEM), graduating in December 2026
with about 3.5 years of prior experience, targeting PM, AI PM and product-analyst roles
in the SF Bay Area and Seattle. OPT plus the STEM extension gives me three registration
seasons (March 2027, 2028 and 2029). I run the mode before a final round at a company
whose posting shows a pay range, and again when an offer fixes the worksite and base
salary.

## The information asymmetry

Since February 27, 2026, a registration gets 1–4 entries according to the highest DOL
wage level the offered wage meets. That level depends on **the SOC code the employer
files**, **the worksite's wage area**, and **base pay**. Product managers have **no SOC
code of their own**. A PM can plausibly be filed as a marketing or IS manager, a
management or systems analyst, "computer occupations, all other", or a data scientist,
and those codes' Level I wages in San Francisco range from $73,258 to $167,565. At
Flexport's posted Senior PM midpoint ($193,500 base, live on 2026-10-21), the official SF
table gives **1 entry** under the IS-manager code and **4** under management analyst.
The posting doesn't say which applies. The employer's counsel knows; the student only
knows to ask after seeing this table.

## Engine layers

**Cognitive Pivot** (OEWS wage distributions by SOC, plus each code's Cognitive Pivot
score). **80 Days** (the employer's H-1B record and the visa-timeline gate). **Job-Ops**
(posting liveness as a hard gate).

## Failure modes specific to this domain

**1. National wage data makes a high-cost-metro salary look higher-level than it is.** A
careful student, or an LLM answering from general knowledge, sees that $174,000 is above
the national 75th percentile for data scientists and concludes "Level IV". The official
San Francisco table says **Level II**. For my three postings, the national shortcut
disagreed with the official level in **23 of 54** comparisons, all in the flattering
direction.

Part of that could be data age: the national file is May 2024 and the official table is
built on May 2025. When I scaled national wages up 10% (several years' growth), **18 of
54** still overstated, so the city, not the year, drives most of the error. The sample is
three postings and a hand-picked set of codes, so the rate isn't general; the direction
is the warning.

It is hardest to catch for the diligent student, because checking BLS data *feels* like
verification. It is also hard for anyone comparing metros: the same national figure is
roughly right in a cheaper city and wrong in SF or Seattle.

**2. A posted pay range is not the offered wage.** Some ranges required by pay-transparency
laws are **on-target earnings**, meaning base plus commission. Verkada's Business Systems
PM posting says so explicitly, and the lottery level is judged on base pay. Read as base,
its $160,000 low end looks like Level III under the systems-analyst code; the true base
is lower by an amount the posting doesn't give. It is hardest to catch for students used
to markets that quote one total "cost to company" figure, and in sales-adjacent PM roles
(partner, commerce, solutions), where OTE wording is common. The mode refuses any range a
person hasn't confirmed as base. It cannot catch a person who confirms it falsely.
