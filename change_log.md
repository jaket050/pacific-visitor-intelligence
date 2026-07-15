# Change Log

## 2026-07-07 — Phase 0: Project Initialization
- Initialized Git repository
- Built full folder structure (raw_data, cleaned_data, sql, scripts, notebooks, outputs, rag)
- Created .gitignore excluding raw_data/, outputs/, and secrets
- Wrote initial README with project overview and status tracker
- Pushed to GitHub: github.com/jaket050/pacific-visitor-intelligence
## 2026-07-07 — Phase 1: Hawaii HTA Data Sourced
- Added 7 years of HTA monthly visitor statistics (2018-2024) to raw_data/hawaii_hta/
- Inventoried sheet structure across all 7 files
- Documented header row offset shift beginning in 2023 (critical finding —
  would silently misalign data if cleaned with fixed row indices)
- Documented label inconsistencies (Domestic/International vs On Domestic/
  International Flights) and sheet name variants (Korean vs Korea)
- Identified RowNum column as the stable anchor for cleaning logic
## 2026-07-07 — Phase 1: Guam GVB Data Sourced
- Bulk-downloaded 84 monthly Arrival Summary PDFs (Jan 2018 - Dec 2024) via
  scripts/ingestion/download_gvb_pdfs.sh
- First pass: 50/84 succeeded. GVB's filename convention switches between
  hyphens and underscores inconsistently across years with no predictable pattern.
- Two retry scripts (download_gvb_pdfs_retry.sh, download_gvb_pdfs_retry2.sh)
  resolved the remaining 34 files by reading exact filenames directly off the
  live GVB page rather than pattern-guessing.
- Verified all 84 files present and none under 5KB (rules out saved error pages).
- Documented in data_dictionary.md: PDF format requires Phase 2 table extraction
  via pdfplumber, unlike HTA's direct-readable Excel files. "Preliminary" vs
  "final" labeling is inconsistent across GVB's own filenames — flagged for
  an is_estimated field in the Phase 3 data model.
## 2026-07-07 — Phase 1.5: GVB PDF Extraction Proof-of-Concept
- Tested pdfplumber extraction on 2023-09-arrival-summary.pdf before committing
  to a full 84-file cleaning pipeline
- Found each PDF has 6 pages of inconsistent layouts (infographic, formal table,
  YTD comparison, monthly matrix)
- Page 3 and 4 (formal tables) extract cleanly via extract_text() + regex
- Pages 5-6 (monthly matrix) are unreliable via extract_tables() - garbled digit
  splitting. Decision: skip these pages, reconstruct monthly trend from page 3
  of each of the 84 files instead
- This changes the Phase 2 approach: text+regex parsing on specific pages,
  not blind extract_tables() across the whole document
- Still need to confirm this layout holds across 2018-2024, not just 2023
## 2026-07-07 — Phase 1.5: GVB Layout Drift Test (2018 vs 2023)
- Tested 2018-01-arrival-summary.pdf against the 2023-09 baseline
- CONFIRMED drift: 2018 files have 4 pages, 2023 have 6. Core table page
  position shifts from page 2 (2018) to page 3 (2023)
- Extraction method itself (extract_text + regex) works identically once
  the correct page is found -- fix is content-based page matching, not a
  different parsing approach
- Also found: Korea sub-region categories (Chungbuk, Gangwon, Jeonnam,
  Ulsan) appear/disappear across years due to a 2017 customs form change,
  noted directly in the source file. Phase 2 cleaning must not assume a
  fixed subcategory list per market.
- Extraction strategy is now considered validated across a 5-year span.
  Ready to proceed to full Phase 2 build.
## 2026-07-08 — Phase 1: First Census Table Sourced (Guam Race/Ethnicity)
- Sourced 2020 Island Areas Census Table P3 (Race/Ethnicity) for Guam via
  data.census.gov, searched by keyword "Chamorro" after initial P1 table
  turned out to be population-count-only
- Confirmed Chamorro population: 50,420 (matches official Census press
  release exactly)
- Documented structural issues: BOM character requiring utf-8-sig encoding,
  comma-formatted number strings, whitespace-based hierarchy encoding
- Four more Census tables still needed: income/poverty by ethnicity, housing
  tenure/value, language at home by age, and CHamoru diaspora by US state (ACS)
## 2026-07-15 — Phase 1: Chamorro-Specific Income Table Sourced (CT14)
- After two dead-end searches in the DHC product (PBG43, PCT74/75 -- both
  capped at "NHPI alone"), found the correct product: "Detailed Cross
  Tabulation," which breaks income down to Chamorro/Carolinian/Chuukese/etc.
- CONFIRMED Chamorro median household income: $61,028 (matches press
  release exactly)
- Table structure is fundamentally different from P3: wide/pivoted single-row
  format with 1,000+ coded columns, requiring a metadata-join to decode,
  vs. P3's simple long/hierarchical format
- Found CRITICAL comparability warning in source notes: 2020 Guam data
  excludes military housing and COVID-era group quarters population,
  making it explicitly NOT comparable to 2010 data without adjustment.
  This must be flagged on any historical trend visualization.
- Also found: this Census release uses raw unformatted numbers (no commas),
  opposite convention from the P3 file -- cleaning script cannot assume
  consistent number formatting across different Census products
