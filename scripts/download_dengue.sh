#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Download raw data for Singapore dengue project
#
# Sources:
# 1) Disease signal: data.gov.sg / MOH weekly dengue dataset
# 2) Weather: Open-Meteo historical archive API
#
# Notes:
# - Safe to rerun
# - Use FORCE=1 ./scripts/download_dengue.sh to overwrite
# - Disease dataset is weekly and officially covers 2014-2018
# -------------------------------------------------------------------

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW_DIR="${PROJECT_ROOT}/data/raw/dengue"
mkdir -p "${RAW_DIR}"

FORCE="${FORCE:-0}"

# -------------------------------------------------------------------
# Singapore dengue weekly dataset (official)
# Dataset page:
# https://data.gov.sg/datasets/d_ac1eecf0886ff0bceefbc51556247015/view
# -------------------------------------------------------------------
DENGUE_DATASET_ID="${DENGUE_DATASET_ID:-d_ac1eecf0886ff0bceefbc51556247015}"
DENGUE_JSON="${RAW_DIR}/dengue_singapore_weekly_2014_2018.json"

# Pull all rows in one call (dataset page shows 530 rows total)
DENGUE_URL="https://data.gov.sg/api/action/datastore_search?resource_id=${DENGUE_DATASET_ID}&limit=2000"

# -------------------------------------------------------------------
# Weather (Singapore coordinates)
# Using central Singapore coordinates for v1
# -------------------------------------------------------------------
LAT="${LAT:-1.3521}"
LON="${LON:-103.8198}"

START_DATE="${START_DATE:-2014-01-01}"
END_DATE="${END_DATE:-2018-12-31}"

WEATHER_JSON="${RAW_DIR}/weather_openmeteo_singapore_${START_DATE}_${END_DATE}.json"

WEATHER_URL="https://archive-api.open-meteo.com/v1/archive?latitude=${LAT}&longitude=${LON}&start_date=${START_DATE}&end_date=${END_DATE}&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,shortwave_radiation_sum&timezone=Asia/Singapore"

# -------------------------------------------------------------------
# helper
# -------------------------------------------------------------------
download_if_needed() {
  local url="$1"
  local out="$2"

  if [[ -f "$out" && "$FORCE" != "1" ]]; then
    echo "Skipping existing file: $out"
    return 0
  fi

  echo "Downloading -> $out"

  # retry loop with exponential backoff
  local max_attempts=8
  local attempt=1
  local delay=3

  while true; do
    http_code=$(curl -s -w "%{http_code}" -o "$out.tmp" "$url")

    if [[ "$http_code" == "200" ]]; then
      mv "$out.tmp" "$out"
      echo "Download successful"
      break
    fi

    echo "Attempt $attempt failed with HTTP $http_code"

    if [[ "$attempt" -ge "$max_attempts" ]]; then
      echo "Max retries reached. Exiting."
      rm -f "$out.tmp"
      exit 1
    fi

    # exponential backoff
    sleep $delay
    delay=$((delay * 2))
    attempt=$((attempt + 1))
  done
}

# -------------------------------------------------------------------
# download
# -------------------------------------------------------------------
download_if_needed "$DENGUE_URL" "$DENGUE_JSON"
download_if_needed "$WEATHER_URL" "$WEATHER_JSON"

# -------------------------------------------------------------------
# metadata
# -------------------------------------------------------------------
META_TXT="${RAW_DIR}/README_raw_sources.txt"

if [[ ! -f "$META_TXT" || "$FORCE" == "1" ]]; then
  cat > "$META_TXT" <<EOF
Raw data files downloaded by scripts/download_dengue.sh

1) Disease signal
   Source: data.gov.sg / MOH
   Dataset: Weekly Number of Dengue and Dengue Haemorrhagic Fever Cases
   Dataset ID: ${DENGUE_DATASET_ID}
   URL: ${DENGUE_URL}
   File: $(basename "$DENGUE_JSON")

2) Weather
   Source: Open-Meteo Historical Weather API
   URL: ${WEATHER_URL}
   File: $(basename "$WEATHER_JSON")

Run notes:
- Re-run safely any time.
- Use FORCE=1 ./scripts/download_dengue.sh to overwrite.
- Disease data is weekly.
- Weather data is daily and will be aggregated in the notebook.
EOF
fi

echo
echo "Done."
echo "Files saved in: ${RAW_DIR}"
ls -lh "${RAW_DIR}"
