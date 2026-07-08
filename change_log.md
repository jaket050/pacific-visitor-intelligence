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
