#!/bin/bash
# Retry script for the 34 GVB files that failed on the first pass
# Filenames verified directly from guamvisitorsbureau.com/research/statistics/visitor-arrival-statistics

OUTDIR="raw_data/guam_gvb"
mkdir -p "$OUTDIR"

declare -A FILES=(
  ["2021-04"]="april-2021-arrival-summary.pdf"
  ["2021-05"]="may-2021-arrival-summary.pdf"
  ["2021-06"]="june-2021-arrival-summary.pdf"
  ["2021-07"]="july-2021-arrival-summary.pdf"
  ["2021-08"]="august-2021-arrival-summary.pdf"
  ["2021-09"]="september-2021-arrival-summary.pdf"
  ["2021-10"]="october-2021-arrival-summary.pdf"
  ["2021-11"]="november-2021-arrival-summary.pdf"
  ["2021-12"]="december-2021-arrival-summary.pdf"
  ["2022-01"]="january_2022_preliminary_arrival_summary_0.pdf"
  ["2022-02"]="february_2022_preliminary_arrival_summary_0.pdf"
  ["2022-03"]="march_2022_preliminary_arrival_summary.pdf"
  ["2022-04"]="april_2022_preliminary_arrival_summary.pdf"
  ["2022-05"]="may_2022_preliminary_arrival_summary.pdf"
  ["2022-06"]="june_2022_preliminary_arrival_summary.pdf"
  ["2022-07"]="july_2022_preliminary_arrival_summary_0.pdf"
  ["2022-08"]="august_2022_preliminary_arrival_summary.pdf"
  ["2022-09"]="september_2022_preliminary_arrival_summary_0.pdf"
  ["2022-10"]="october_2022_arrival_summary.pdf"
  ["2022-11"]="november_2022_arrival_summary.pdf"
  ["2022-12"]="december_2022_arrival_summary.pdf"
  ["2023-01"]="january_2023_arrival_summary.pdf"
  ["2023-02"]="february_2023_arrival_summary.pdf"
  ["2023-03"]="march_2023_arrival_summary.pdf"
  ["2023-04"]="april_2023_arrival_summary.pdf"
  ["2023-05"]="may_2023_arrival_summary.pdf"
  ["2023-06"]="june_2023_arrival_summary.pdf"
  ["2023-07"]="july_2023_arrival_summary.pdf"
  ["2023-08"]="august_2023_arrival_summary.pdf"
  ["2023-09"]="september_2023_arrival_summary.pdf"
  ["2023-10"]="october_2023_preliminary_arrival_summary.pdf"
  ["2023-11"]="november_2023_preliminary_arrival_summary.pdf"
  ["2023-12"]="december_2023_preliminary_arrival_summary.pdf"
  ["2024-01"]="january_2024_preliminary_arrival_summary_revised.pdf"
)

BASE_URL="https://www.guamvisitorsbureau.com/sites/default/files"
SUCCESS=0
FAILED=0
FAILED_LIST=()

for period in "${!FILES[@]}"; do
  fname="${FILES[$period]}"
  outfile="$OUTDIR/${period}-arrival-summary.pdf"
  echo "Retrying $period..."
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
echo "=== Retry Summary ==="
echo "Success: $SUCCESS / 33"
echo "Failed: $FAILED"
if [ $FAILED -gt 0 ]; then
  echo "Failed periods: ${FAILED_LIST[@]}"
fi
