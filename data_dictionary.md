# Data Dictionary
## Pacific Visitor Intelligence

---

## Source: Hawaii Tourism Authority — Monthly Visitor Statistics

**Files:** `raw_data/hawaii_hta/2018-monthly-visitor-statistics.xlsx` through
`2024-monthly-visitor-statistics-final.xlsx` (7 files, one per year, 2018–2024)

**Source:** Hawaii Tourism Authority, hawaiitourismauthority.org

**Structure:** Each file contains 18–21 sheets. Core sheets present in every year:
`State`, `US West`, `US East`, `Japan`, `Canada`, `Oceania`, `Australia`,
`New Zealand`, `Other Asia`, `China`, `Korea`, `Taiwan`, `Europe`,
`Latin America`, `Exp by MMA`, `Exp by Island`, `Days by Island`, `CRUISE`

### Known Structural Inconsistencies (documented before cleaning)

1. **Header row offset shifts in 2023–2024.**
   2018–2022: RowNum in row 0, year in row 1, month headers (JAN, FEB...) in row 0.
   2023–2024: title text in row 0, month headers shifted down to row 2.
   Cleaning script must NOT use fixed row indices. Must anchor on the
   `RowNum` column (col A), which is stable across all years.
   `RowNum = 30` = TOTAL VISITORS row in every year, every sheet.

2. **Label text changes for the same field.**
   2018–2019: `Domestic` / `International`
   2020–2024: `On Domestic Flights` / `On International Flights`
   Both must map to the same standardized field name during cleaning.

3. **Sheet name inconsistency.**
   2018 only: Korea tab is named `Korean` (every other year: `Korea`)
   2018 only: has an extra `Seats` tab not present in other years

4. **2023–2024 restructured the island/day breakdown.**
   2018–2022: single `Days by Island` tab
   2023–2024: split into `Visitor Days by MMA`, `Visitor Days by Island`,
   `Visitors by MMA`, `Visitors by Island`

5. **Footnotes appear at the bottom of every sheet after real data ends**
   (sample size caveats, rounding notes, "NA = Not applicable"). These rows
   have blank or non-numeric RowNum values and must be excluded during
   cleaning, not parsed as data.

### Cleaning Rule
Never reference fixed row/column numbers. Always locate data by:
- `RowNum` value (stable numeric code, e.g. 30 = TOTAL VISITORS)
- Row label text in column B (normalized to handle label changes above)

---

## Source: Guam Visitors Bureau — Monthly Arrival Summary

**Files:** `raw_data/guam_gvb/YYYY-MM-arrival-summary.pdf` (84 files, Jan 2018 – Dec 2024)

**Source:** Guam Visitors Bureau, guamvisitorsbureau.com/research/statistics/visitor-arrival-statistics

**Format:** PDF (unlike HTA's Excel files — these require table extraction via pdfplumber
in Phase 2, not direct pandas reading)

**Contents per report:** Civilian/military air and sea arrivals, market mix by source
country, hotel occupancy rates, and tax collections for the given month.

### Known Sourcing Issues (documented before extraction)

1. **Inconsistent filename conventions on GVB's own site.** GVB's naming switches
   between hyphens and underscores with no predictable pattern across years, and some
   files include revision suffixes (`_0`, `_draft`, `_revised`). This project standardizes
   all local filenames to `YYYY-MM-arrival-summary.pdf` regardless of the source filename,
   documented in `scripts/ingestion/download_gvb_pdfs.sh` and its two retry scripts.

2. **"Preliminary" vs "Final" labeling is inconsistent.** Some months are explicitly
   marked preliminary in the source filename (e.g., "preliminary_arrival_summary"),
   others are not labeled at all. GVB does not appear to re-publish a clearly marked
   "final" version for every preliminary report. This needs a `is_estimated` flag in
   the Phase 3 data model (already planned for), defaulting to TRUE unless a report
   explicitly says final.

3. **PDF extraction quality is unverified as of Phase 1.** These are scanned/generated
   PDF tables, not spreadsheets. Table structure consistency across 84 files (2018-2024)
   has not yet been tested. Phase 2 must validate extracted totals against at least one
   independently known figure per year (e.g., published annual totals from GVB Annual
   Reports) before trusting the full extraction pipeline.

### Sourcing Rule
All 84 files were bulk-downloaded via `scripts/ingestion/download_gvb_pdfs.sh` (+ 2
retry scripts for filename mismatches). Every file was verified for a non-trivial file
size (>5KB) to rule out silently saved error pages.

## Source: US Census Island Areas 2020
*To be documented once files are sourced*
