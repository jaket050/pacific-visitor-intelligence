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

## Source: Guam Visitors Bureau
*To be documented once files are sourced*

## Source: US Census Island Areas 2020
*To be documented once files are sourced*
