#!/bin/bash
# Final retry - filenames copied exactly from live GVB page markup
OUTDIR="raw_data/guam_gvb"
mkdir -p "$OUTDIR"

declare -A FILES=(
  ["2021-04"]="april_2021_arrival_summary.pdf"
  ["2021-05"]="may_2021_arrival_summary.pdf"
  ["2021-06"]="june_2021_arrival_summary.pdf"
  ["2021-07"]="july_2021_arrival_summary.pdf"
  ["2021-08"]="august_2021_arrival_summary.pdf"
  ["2021-09"]="september_2021_arrival_summary.pdf"
  ["2021-10"]="october_2021_arrival_summary.pdf"
  ["2021-11"]="november_2021_arrival_summary.pdf"
  ["2021-12"]="december_2021_arrival_summary.pdf"
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
      FAILED=$((FAILED+1)); FAILED_LIST+=("$period"); rm -f "$outfile"
    fi
  else
    FAILED=$((FAILED+1)); FAILED_LIST+=("$period"); rm -f "$outfile"
  fi
done

echo ""
echo "=== Final Retry Summary ==="
echo "Success: $SUCCESS / 9"
echo "Failed: $FAILED"
[ $FAILED -gt 0 ] && echo "Failed periods: ${FAILED_LIST[@]}"
