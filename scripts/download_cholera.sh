#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW_DIR="${PROJECT_ROOT}/data/raw/cholera"
mkdir -p "${RAW_DIR}"

FORCE="${FORCE:-0}"

# Bangladesh representative location for v1: Dhaka
LAT="${LAT:-23.8103}"
LON="${LON:-90.4125}"

# Start with a modern period that matches publicly visible WHO dashboard downloads
START_DATE="${START_DATE:-2023-01-01}"
END_DATE="${END_DATE:-2024-12-31}"

WEATHER_JSON="${RAW_DIR}/weather_openmeteo_dhaka_${START_DATE}_${END_DATE}.json"
WEATHER_URL="https://archive-api.open-meteo.com/v1/archive?latitude=${LAT}&longitude=${LON}&start_date=${START_DATE}&end_date=${END_DATE}&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,shortwave_radiation_sum&timezone=Asia/Dhaka"

download_if_needed() {
  local url="$1"
  local out="$2"

  if [[ -f "$out" && "$FORCE" != "1" ]]; then
    echo "Skipping existing file: $out"
    return 0
  fi

  echo "Downloading -> $out"
  curl --fail --silent --show-error \
       --location \
       --retry 6 \
       --retry-delay 3 \
       --retry-max-time 120 \
       "$url" \
       -o "$out"
}

download_if_needed "$WEATHER_URL" "$WEATHER_JSON"

META_TXT="${RAW_DIR}/README_raw_sources.txt"

cat > "$META_TXT" <<EOF
Raw data files for Bangladesh cholera project

1) Disease signal
   RECOMMENDED SOURCE OPTIONS:

   A. WHO Global Cholera and AWD Dashboard
      Public dashboard:
      https://who-global-cholera-and-awd-dashboard-1-who.hub.arcgis.com/
      Data download page:
      https://who-global-cholera-and-awd-dashboard-1-who.hub.arcgis.com/pages/data-download

      NOTE:
      The public download page currently advertises downloadable global data
      for the years 2023 and 2024.

   B. WHO Bangladesh EWARS archive
      Archive:
      https://www.who.int/bangladesh/emergencies/Rohingyacrisis/ewars-archive

   IMPORTANT:
   Once you choose/download the cholera disease file, save it into:
   data/raw/cholera/

   Suggested names:
   - cholera_bangladesh_weekly_2023_2024.csv
   - cholera_bangladesh_weekly_2023_2024.xlsx
   - cholera_bangladesh_weekly_ewars.pdf

2) Weather
   Source: Open-Meteo Historical Weather API
   URL: ${WEATHER_URL}
   File: $(basename "$WEATHER_JSON")

Notes:
- This script only automates the weather pull.
- The cholera disease source is intentionally left manual for now because the
  public data sources are dashboard/bulletin-oriented rather than one stable,
  clean weekly API like flu or dengue.
EOF

echo
echo "Done."
echo "Files saved in: ${RAW_DIR}"
ls -lh "${RAW_DIR}"
