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

## Table CT14 Sourced: Income by Race/Ethnicity of Householder

**Files:** `raw_data/census/guam_income_poverty/ct14_income_by_ethnicity/`
(3 files: -Data.csv, -Column-Metadata.csv, -Table-Notes.txt)

**Source product:** "2020: DECIA Guam Detailed Crosstabulations" — a DIFFERENT
Census product than the P3 table (which came from "DECIA Guam Demographic and
Housing Characteristics"/DHC). Detailed Crosstabulations is the only product
that breaks ethnicity down to the Chamorro/Carolinian/Chuukese level for
income and poverty; DHC and standard DHC-derived tables (PBG43, PCT74/75)
only go as fine as "NHPI alone."

**CONFIRMED: Chamorro median household income = $61,028** (matches official
press release exactly). Full income distribution across 12 brackets also
included, plus mean income, earnings, wage/salary, self-employment, Social
Security, public assistance, and retirement income breakdowns -- all by
specific ethnicity (Carolinian, Chamorro, Chuukese, Kosraean, Marshallese,
Palauan, Pohnpeian, Yapese, plus Asian subgroups, White, Hispanic origin
groups, etc.)

### Known Structural Issues (very different shape than P3)

1. **Wide/pivoted format, not long format.** ONE row represents the entirety
   of Guam. Over 1,000 columns, each a unique ethnicity x income-metric
   combination. This is the opposite structure from P3, which had one row
   per category. Cleaning script cannot reuse the P3 indent-parsing approach --
   this needs a metadata-join: match Column-Metadata.csv's "Label" text
   (e.g. containing "Chamorro" AND "Median household income") to find the
   right coded column name, then pull that column's value from Data.csv.

2. **Column headers are opaque codes** (CT14_COL1_R1, CT14_COL1_R2, ...),
   decoded only via the separate Column-Metadata.csv file. Never hardcode
   column positions -- always join on the metadata file's Label text.

3. **Numbers here are RAW digits, no comma formatting** (e.g. "61028" not
   "61,028") -- opposite convention from the P3 file, which used
   comma-formatted text. Cleaning script must NOT assume consistent number
   formatting across different Census table exports, even within the same
   overall Census release.

4. **Suppression/special-value symbols require explicit handling, not silent
   NaN coercion:**
   - `N` = data not displayed (reliability concern / too few cases)
   - `-` = insufficient observations, OR median falls in lowest bracket
     (context-dependent meaning -- same symbol, two different meanings)
   - `+` = median falls in highest open-ended bracket
   - `(X)` = not applicable
   Cleaning script must map these to explicit flags, not just pd.to_numeric
   with errors='coerce', which would silently convert all four to identical
   NaN and lose the distinction.

5. **CRITICAL COMPARABILITY WARNING (from source Table-Notes.txt):** 2020
   Guam data EXCLUDES military housing units (operational change) AND
   EXCLUDES group quarters population (COVID-19 collection impact). The
   Census Bureau explicitly warns these 2020 tables should NOT be compared
   to 2010 or earlier data for the same measures without accounting for
   this. THIS AFFECTS ANY FUTURE 2010-vs-2020 TREND ANALYSIS using this
   table or related income/poverty tables. Must be flagged prominently on
   any dashboard panel or chart that would otherwise imply a clean
   historical trend line.

6. **This table has no village-level breakdown** -- unlike P3, which had a
   column per village (Adacao CDP, Afame CDP, etc.), CT14 only reports at
   the whole-of-Guam level. Likely due to small-sample reliability concerns
   for detailed ethnicity x income cross-tabs at finer geography.

### Sourcing note
Found only after two earlier search attempts (PBG43, PCT74/75) surfaced
DHC-product tables capped at "NHPI alone" -- not granular enough. The
correct product name to search for granular ethnicity data is specifically
"Detailed Cross Tabulation," a separate release from the standard DHC tables.

## Table CT15 Sourced: Poverty Status by Race/Ethnicity of Householder

**File:** `raw_data/census/guam_income_poverty/2020_census_ct15_poverty_by_ethnicity.csv`

**Source product:** Same "Detailed Cross Tabulation" release as CT14, found
immediately via the same search pattern this time (searched "poverty status
Chamorro" directly).

**CONFIRMED: Chamorro family poverty rate = 17.5%.** Sits right next to
Chuukese at 58.0% in the same table -- a greater than 3x gap between two
ethnic groups that the broader "NHPI alone" aggregate (28.5% individual
poverty rate, sourced earlier from PBG-series tables) was masking entirely.
IMPORTANT: the 28.5% figure measures INDIVIDUALS NHPI-alone; this 17.5%
measures FAMILIES specifically Chamorro. Different metric, different
population scope -- not a contradiction, but must be labeled precisely on
any dashboard panel to avoid implying they measure the same thing.

Also includes breakdowns by family structure (married couple / male
householder no spouse / female householder no spouse) and by presence and
age of children (under 18, under 5) and by age of individuals (18+, 65+).
Rich enough to show whether poverty concentrates in single-parent
households or elderly residents, by specific ethnicity.

### Known Structural Issues (a THIRD distinct format, different from P3 and CT14)

1. **Long format** (one row per label/statistic), same general shape as P3 --
   NOT the wide single-row format CT14's raw Data.csv used. This is the
   "Table-view CSV" export option; CT14 was downloaded as the "ZIP:
   machine-readable" option instead. LESSON: the SAME Census product can
   export in fundamentally different shapes depending on which download
   format is selected at download time. Always inspect the actual file,
   never assume format based on table ID or product name alone.

2. **Ethnicity encoded directly in column headers**, using "!!" as a
   hierarchy delimiter, e.g. "Guam!!One Race!!Native Hawaiian and Other
   Pacific Islander!!Chamorro". This is actually the CLEANEST structure
   found so far -- a pandas melt() on column names split by "!!" cleanly
   separates geography, race tier, and specific ethnicity into their own
   fields.

3. **Comma-formatted number strings** ("145,543" not 145543) -- same
   convention as P3, OPPOSITE of CT14's raw-digit Data.csv. Confirms number
   formatting is tied to DOWNLOAD FORMAT CHOICE (Table-view CSV vs.
   machine-readable ZIP), not to the underlying Census product itself.
   Cleaning script must never assume a single number-formatting convention
   applies project-wide -- must check per file.

4. **Same BOM character issue as P3** -- requires utf-8-sig encoding.

5. **Blank cells represent category headers with no data of their own**
   (e.g. "ALL INCOME LEVELS IN 2019" row has empty values across all
   columns -- it's a section label, not a missing data point). Cleaning
   script must distinguish structural header rows from true missing/
   suppressed values (which use the N/-/+ symbols documented for CT14).

### Still to Source (Phase 1 continues)
- Housing tenure and home value by village (likely back in the DHC product,
  not Detailed Cross Tabulation, since this is a housing not income/poverty
  measure -- may reintroduce the "NHPI alone" ceiling; check if a village-
  level Chamorro-specific housing table exists at all)
- Language spoken at home by age group
- CHamoru diaspora population by US state (ACS, not DECIA)
