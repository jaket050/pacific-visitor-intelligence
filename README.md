# Pacific Visitor Intelligence
## Hawaii and Guam Tourism Recovery + Community Displacement Analysis (2010–2024)

---

### What This Project Is

Hawaii and Guam are two Pacific economies that both collapsed in 2020 and are
recovering at very different rates. Hawaii is near pre-pandemic visitor spending
levels. Guam is at 44% of 2019 arrivals with 78.9% of its visitors coming from
just two countries.

This project builds a complete analytics system — from raw PDF data extraction
through a cloud data warehouse to AI-powered natural language querying — to
answer three questions:

1. Where are Hawaii and Guam in their tourism recovery, and which markets are
   driving or dragging it?
2. Who on the island is benefiting from the recovery, and who is being displaced?
3. What is happening to the CHamoru and Native Hawaiian populations as tourism
   revenue climbs back toward 2019 levels?

---

### Dashboards (Tableau Public)
*Links added when dashboards are published*

- Dashboard 1: Tourism Recovery Overview
- Dashboard 2: Guam Risk and Opportunity
- Dashboard 3: Hawaii Island Equity
- Dashboard 4: Community Displacement

---

### RAG Query Interface
*Link added when Streamlit app is deployed*

Ask natural language questions against the full dataset.
Example: "What is the CHamoru poverty rate compared to the overall Guam rate?"

---

### Data Sources

| Source | Contents | Update Frequency |
|---|---|---|
| Hawaii Tourism Authority | Annual visitor reports 2018–2024 | Annual + Monthly |
| Guam Visitors Bureau | Monthly arrivals, market mix, tax revenue | Monthly |
| DBEDT Hawaii | Air capacity, quarterly tourism stats | Quarterly |
| US Census Island Areas 2020 | CHamoru population, income, poverty, housing | Decennial |
| Census ACS 5-Year | CHamoru diaspora by US state | Annual |
| HUD / ALICE Reports | Hawaii and Guam housing cost burden | Annual / Biennial |

---

### Tools and Skills Demonstrated

**Data Engineering:** Python (pandas, pdfplumber), Snowflake, Snowpipe,
Snowflake Tasks and Streams, ETL pipeline design, dimensional modeling

**Data Analytics:** SQL (CTEs, window functions), statistical analysis,
scenario modeling, EDA, Tableau Public

**AI Engineering:** RAG architecture, embeddings, ChromaDB, Claude API,
prompt engineering, Streamlit

---

### How to Run Locally

*Setup instructions added as each phase is completed*

---

### Known Limitations

- Community population data is from the 2020 Island Areas Census.
  Next update: 2030.
- Some GVB figures are extracted from PDF and validated against
  published totals. Extraction quality is documented in change_log.md.
- 2020 tourism data reflects COVID lockdown periods and is retained
  as-is with documentation, not imputed.

---

### Project Status

| Phase | Status |
|---|---|
| Phase 0: Setup and structure | Complete |
| Phase 1: Data sourcing | Not started |
| Phase 2: ETL pipeline | Not started |
| Phase 3: Data modeling | Not started |
| Phase 4: SQL analysis | Not started |
| Phase 5: EDA and statistics | Not started |
| Phase 6: Dashboards | Not started |
| Phase 7: RAG layer | Not started |
| Phase 8: Documentation | Not started |

---

*Built by Jake T | github.com/jaket050/pacific-visitor-intelligence*
