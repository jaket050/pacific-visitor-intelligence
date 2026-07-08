#!/bin/bash
# Downloads GVB Monthly Arrival Summary PDFs, 2018-2024
# Saves into raw_data/guam_gvb/ with standardized YYYY-MM naming

OUTDIR="raw_data/guam_gvb"
mkdir -p "$OUTDIR"

declare -A FILES=(
  ["2018-01"]="january-2018-arrival-summary-20190314.pdf"
  ["2018-02"]="february-2018-arrival-summary-20190314.pdf"
  ["2018-03"]="march-2018-arrival-summary-20190314_0.pdf"
  ["2018-04"]="april-2018-arrival-summary-20190314.pdf"
  ["2018-05"]="may-2018-arrival-summary-20190314.pdf"
  ["2018-06"]="june-2018-arrival-summary-20190314.pdf"
  ["2018-07"]="july-2018-arrival-summary-20190314.pdf"
  ["2018-08"]="august-2018-arrival-summary-20190314.pdf"
  ["2018-09"]="september-2018-arrival-summary-20190314.pdf"
  ["2018-10"]="october-2018-arrival-summary-2019050713.pdf"
  ["2018-11"]="november-2018-arrival-summary-20190314.pdf"
  ["2018-12"]="december-2018-arrival-summary-20190314.pdf"
  ["2019-01"]="january-2019-arrival-summary.pdf"
  ["2019-02"]="february-2019-arrival-summary.pdf"
  ["2019-03"]="march-2019-arrival-summary.pdf"
  ["2019-04"]="april-2019-arrival-summary.pdf"
  ["2019-05"]="may-2019-arrival-summary.pdf"
  ["2019-06"]="june-2019-arrival-summary.pdf"
  ["2019-07"]="july-2019-arrival-summary.pdf"
  ["2019-08"]="august-2019-arrival-summary.pdf"
  ["2019-09"]="september-2019-arrival-summary.pdf"
  ["2019-10"]="october-2019-arrival-summary.pdf"
  ["2019-11"]="november-2019-arrival-summary-20200612.pdf"
  ["2019-12"]="december-2019-arrival-summary-20200612.pdf"
  ["2020-01"]="january-2020-arrival-summary-20200612.pdf"
  ["2020-02"]="february-2020-arrival-summary-20200612.pdf"
  ["2020-03"]="march-2020-arrival-summary.pdf"
  ["2020-04"]="april-2020-arrival-summary.pdf"
  ["2020-05"]="may-2020-arrival-summary.pdf"
  ["2020-06"]="june-2020-arrival-summary.pdf"
  ["2020-07"]="july-2020-arrival-summary.pdf"
  ["2020-08"]="august-2020-arrival-summary.pdf"
  ["2020-09"]="september-2020-arrival-summary-20210115.pdf"
  ["2020-10"]="october-2020-arrival-summary_0.pdf"
  ["2020-11"]="november-2020-arrival-summary_0.pdf"
  ["2020-12"]="december-2020-arrival-summary_0.pdf"
  ["2021-01"]="january-2021-arrival-summary_0.pdf"
  ["2021-02"]="february-2021-arrival-summary_0.pdf"
  ["2021-03"]="march-2021-arrival-summary_0.pdf"
  ["2021-04"]="april-2021-arrival-summary.pdf"
  ["2021-05"]="may-2021-arrival-summary.pdf"
  ["2021-06"]="june-2021-arrival-summary.pdf"
  ["2021-07"]="july-2021-arrival-summary.pdf"
  ["2021-08"]="august-2021-arrival-summary.pdf"
  ["2021-09"]="september-2021-arrival-summary.pdf"
  ["2021-10"]="october-2021-arrival-summary.pdf"
  ["2021-11"]="november-2021-arrival-summary.pdf"
  ["2021-12"]="december-2021-arrival-summary.pdf"
  ["2022-01"]="january-2022-preliminary-arrival-summary_0.pdf"
  ["2022-02"]="february-2022-preliminary-arrival-summary_0.pdf"
  ["2022-03"]="march-2022-preliminary-arrival-summary.pdf"
  ["2022-04"]="april-2022-preliminary-arrival-summary.pdf"
  ["2022-05"]="may-2022-preliminary-arrival-summary.pdf"
  ["2022-06"]="june-2022-preliminary-arrival-summary.pdf"
  ["2022-07"]="july-2022-preliminary-arrival-summary_0.pdf"
  ["2022-08"]="august-2022-preliminary-arrival-summary.pdf"
  ["2022-09"]="september-2022-preliminary-arrival-summary_0.pdf"
  ["2022-10"]="october-2022-arrival-summary.pdf"
  ["2022-11"]="november-2022-arrival-summary.pdf"
  ["2022-12"]="december-2022-arrival-summary.pdf"
  ["2023-01"]="january-2023-arrival-summary.pdf"
  ["2023-02"]="february-2023-arrival-summary.pdf"
  ["2023-03"]="march-2023-arrival-summary.pdf"
  ["2023-04"]="april-2023-arrival-summary.pdf"
  ["2023-05"]="may-2023-arrival-summary.pdf"
  ["2023-06"]="june-2023-arrival-summary.pdf"
  ["2023-07"]="july-2023-arrival-summary.pdf"
  ["2023-08"]="august-2023-arrival-summary.pdf"
  ["2023-09"]="september-2023-arrival-summary.pdf"
  ["2023-10"]="october-2023-preliminary-arrival-summary.pdf"
  ["2023-11"]="november-2023-preliminary-arrival-summary.pdf"
  ["2023-12"]="december-2023-preliminary-arrival-summary.pdf"
  ["2024-01"]="january-2024-preliminary-arrival-summary-revised.pdf"
  ["2024-02"]="guam_daily_arrivals_-_february_1-29-_2024.pdf"
  ["2024-03"]="march_2024_arrival_summary.pdf"
  ["2024-04"]="april_2024_arrival_summary.pdf"
  ["2024-05"]="guam_daily_arrivals_-_may_1-31_2024.pdf"
  ["2024-06"]="june_2024_preliminary_arrival_summary_d.pdf"
  ["2024-07"]="july_2024_preliminary_arrival_summary_draft.pdf"
  ["2024-08"]="guam_daily_arrivals_-_august_1-31_2024.pdf"
  ["2024-09"]="guam_daily_arrivals_-_september_1-30_2024.pdf"
  ["2024-10"]="october_2024_preliminary_arrival_summary_draft.pdf"
  ["2024-11"]="november_2024_arrival_summary_draft_revised_2025.pdf"
  ["2024-12"]="december_2024_arrival_summary_draft_revised_2025.pdf"
)

BASE_URL="https://www.guamvisitorsbureau.com/sites/default/files"
SUCCESS=0
FAILED=0
FAILED_LIST=()

for period in "${!FILES[@]}"; do
  fname="${FILES[$period]}"
  outfile="$OUTDIR/${period}-arrival-summary.pdf"
  echo "Downloading $period..."
  if wget -q "$BASE_URL/$fname" -O "$outfile"; then
    if [ -s "$outfile" ]; then
      SUCCESS=$((SUCCESS+1))
    else
      FAILED=$((FAILED+1))
      FAILED_LIST+=("$period")
      rm -f "$outfile"
    fi
  else
    FAILED=$((FAILED+1))
    FAILED_LIST+=("$period")
    rm -f "$outfile"
  fi
done

echo ""
echo "=== Download Summary ==="
echo "Success: $SUCCESS / 84"
echo "Failed: $FAILED"
if [ $FAILED -gt 0 ]; then
  echo "Failed periods: ${FAILED_LIST[@]}"
fi
