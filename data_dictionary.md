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

3. **PDF extraction tested via proof-of-concept (2023-09 file). Results: mixed by page.**
   Each GVB monthly PDF contains 6 pages of different layouts, not one clean table:
   - Pages 1-2 (infographic summary): mostly unusable for structured extraction —
     icon-based visual layout, not real tabular data
   - Page 3 ("Visitor Arrival Summary" formal table): CLEAN. Reliable line-by-line
     text via extract_text(), consistent "Label  value  value  %" pattern. This is
     the primary extraction target — contains month total + full country/region
     breakdown.
   - Page 4 (CYTD/FYTD comparison table): CLEAN. Same extraction approach as page 3.
   - Pages 5-6 (12-month rolling matrix): BROKEN via extract_tables() — pdfplumber
     garbles multi-column dense numeric layout, splitting digits across cells.
     DECISION: skip these pages entirely. They are redundant — our own pipeline
     reconstructs the same month-over-month view by processing all 84 files
     sequentially using the clean data from page 3 of each file.

   Phase 2 extraction strategy: use extract_text() + regex line parsing on pages 3
   and 4 only, anchored on label text (TOTAL VISITOR ARRIVALS, JAPAN, KOREA, etc.)
   at the start of each line. Do NOT use extract_tables() for this source — tested
   and found unreliable on the dense numeric matrix layout.

   4. **CONFIRMED: page count and page position drift between years.** Tested
   2018-01 against 2023-09. 2018 files have 4 pages total; 2023 files have 6.
   The core "Visitor Arrival Summary" table sits on page 2 in 2018 but page 3
   in 2023. The CYTD/FYTD table sits on page 3 in 2018 but page 4 in 2023.

   RESOLUTION: extraction must never assume a fixed page number. Instead,
   scan every page's extract_text() output and match on the page's first
   line of text:
   - Page whose text starts with "Visitor Arrival Summary" -> the core
     monthly table (TOTAL VISITOR ARRIVALS + full market breakdown)
   - Page whose text contains "Calendar Year-to-Date" -> the CYTD/FYTD table
   This mirrors the RowNum anchoring strategy used for HTA: never trust
   position, always trust a stable content marker.

   GOOD NEWS: the actual extraction method (extract_text() + regex line
   parsing) works identically on both years once the correct page is located.
   The garbled extract_tables() problem found on 2023's monthly matrix pages
   is avoided entirely since we only ever target these two content-anchored
   pages, never the matrix/infographic pages.

   Still unverified: label/subcategory consistency within KOREA and other
   markets. 2018 shows *Chungbuk, *Gangwon, *Jeonnam, *Ulsan appearing and
   disappearing between years (noted in-file: "Due to the implementation of
   the New Customs Forms in December 2017, countries have been added or
   omitted based on visitor market trends"). This is a content/schema
   consistency issue for Phase 2, not an extraction issue -- cleaning script
   must handle variable subcategory lists per market, not assume a fixed set.

### Sourcing Rule
All 84 files were bulk-downloaded via `scripts/ingestion/download_gvb_pdfs.sh` (+ 2
retry scripts for filename mismatches). Every file was verified for a non-trivial file
size (>5KB) to rule out silently saved error pages.

## Source: US Census Bureau — 2020 Island Areas Census (DECIA), Guam

**Portal:** data.census.gov, filtered to "2020: DECIA Guam Demographic and Housing
Characteristics" (the Guam-specific Island Areas program, not the standard
50-state Decennial Census product)

**Table 1 sourced:** `raw_data/census/guam_dhc/2020_census_p3_race_ethnicity.csv`
(Table ID: P3, confirmed from filename — note the on-screen product picker
labeled this "P1" but the actual downloaded file metadata says P3; trust the
file, not the UI label)

**Contents:** Full race and ethnicity breakdown for Guam, including CHamoru
as a distinct line (50,420 people, matches official press release figure
exactly) nested under Native Hawaiian and Other Pacific Islander (70,809),
alongside Asian subgroups, White, Black, multiracial combinations, etc.

### Known Structural Issues

1. **BOM character at file start.** File begins with an invisible byte-order-mark
   character before "Label". Must load with `encoding='utf-8-sig'` in pandas,
   not default utf-8, or the first column header will silently fail to match.

2. **Numbers stored as comma-formatted text**, e.g. `"153,836"` not `153836`.
   Requires `.str.replace(',', '')` and cast to int before any aggregation.

3. **Hierarchy encoded as leading whitespace indentation**, not a separate
   parent-category column. E.g. "Chamorro" has 12 leading spaces (3 levels
   deep: Total > One Race > NHPI > Chamorro). Cleaning script must parse
   indent depth to reconstruct the category tree, not treat this as a flat list.

### Still to Source (Phase 1 continues)
- Median household income by race/ethnicity of householder (confirms $61,028
  CHamoru figure from press release)
- Poverty status by race/ethnicity (confirms 28.5% NHPI figure)
- Housing tenure and home value by village
- Language spoken at home by age group
- CHamoru diaspora population by US state (separate source: ACS, not DECIA —
  covers the 50 states, not Guam)
