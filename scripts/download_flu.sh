#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Download raw data for Illinois flu project
#
# Sources:
# 1) Disease signal: Delphi Epidata fluview endpoint (CDC FluView-backed)
# 2) Weather: Open-Meteo historical archive API
#
# Notes:
# - This script is idempotent: it can be run multiple times.
# - Use FORCE=1 ./scripts/download_flu.sh to overwrite existing files.
# - Weather is v1 using one representative point (Springfield, IL).
#   Later we can switch to multiple Illinois coordinates if needed.
# -------------------------------------------------------------------

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW_DIR="${PROJECT_ROOT}/data/raw/flu"
mkdir -p "${RAW_DIR}"

FORCE="${FORCE:-0}"

# Illinois flu: start at 2010w40 for public state-level consistency
START_EPIWEEK="${START_EPIWEEK:-201040}"
END_EPIWEEK="${END_EPIWEEK:-202652}"

# Weather range aligned approximately with 2010w40 onward
START_DATE="${START_DATE:-2010-10-01}"
END_DATE="${END_DATE:-2026-04-10}"

# Representative Illinois point for v1:
# Springfield, IL
LAT="${LAT:-39.7817}"
LON="${LON:-89.6501}"

# ---------------------------
# helper functions
# ---------------------------

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

# ---------------------------
# 1) Disease signal (weekly ILI)
# ---------------------------

FLU_JSON="${RAW_DIR}/fluview_il_${START_EPIWEEK}_${END_EPIWEEK}.json"

FLU_URL="https://api.delphi.cmu.edu/epidata/fluview/?regions=il&epiweeks=${START_EPIWEEK}-${END_EPIWEEK}"

download_if_needed "$FLU_URL" "$FLU_JSON"

# ---------------------------
# 2) Weather data (daily)
# ---------------------------
# We are grabbing daily variables that are realistic first-pass features.
# Weekly aggregation will be done in the notebook.
#
# Requested daily variables:
# - temperature_2m_max
# - temperature_2m_min
# - precipitation_sum
# - wind_speed_10m_max
# - shortwave_radiation_sum
#
# You can later add:
# - sunshine_duration
# - et0_fao_evapotranspiration
# - rain_sum
# - snowfall_sum
# ---------------------------

WEATHER_JSON="${RAW_DIR}/weather_openmeteo_springfield_il_${START_DATE}_${END_DATE}.json"

WEATHER_URL="https://archive-api.open-meteo.com/v1/archive?latitude=${LAT}&longitude=${LON}&start_date=${START_DATE}&end_date=${END_DATE}&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,shortwave_radiation_sum&timezone=America/Chicago"

download_if_needed "$WEATHER_URL" "$WEATHER_JSON"

# ---------------------------
# 3) Metadata / provenance
# ---------------------------

META_TXT="${RAW_DIR}/README_raw_sources.txt"

if [[ ! -f "$META_TXT" || "$FORCE" == "1" ]]; then
  cat > "$META_TXT" <<EOF
Raw data files downloaded by scripts/download_flu.sh

1) Disease signal
   Source: Delphi Epidata fluview endpoint (CDC FluView-backed)
   URL: ${FLU_URL}
   File: $(basename "$FLU_JSON")

2) Weather
   Source: Open-Meteo Historical Weather API
   URL: ${WEATHER_URL}
   File: $(basename "$WEATHER_JSON")

Run notes:
- Re-run safely any time.
- Use FORCE=1 ./scripts/download_flu.sh to overwrite.
- Weekly aggregation and merge are done later in the notebook.
EOF
fi

echo
echo "Done."
echo "Files saved in: ${RAW_DIR}"
ls -lh "${RAW_DIR}"
