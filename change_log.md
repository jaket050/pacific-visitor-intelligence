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
