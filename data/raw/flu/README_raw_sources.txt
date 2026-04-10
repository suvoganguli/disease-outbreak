Raw data files downloaded by scripts/download_flu.sh

1) Disease signal
   Source: Delphi Epidata fluview endpoint (CDC FluView-backed)
   URL: https://api.delphi.cmu.edu/epidata/fluview/?regions=il&epiweeks=201040-202652
   File: fluview_il_201040_202652.json

2) Weather
   Source: Open-Meteo Historical Weather API
   URL: https://archive-api.open-meteo.com/v1/archive?latitude=39.7817&longitude=89.6501&start_date=2010-10-01&end_date=2026-04-10&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,shortwave_radiation_sum&timezone=America/Chicago
   File: weather_openmeteo_springfield_il_2010-10-01_2026-04-10.json

Run notes:
- Re-run safely any time.
- Use FORCE=1 ./scripts/download_flu.sh to overwrite.
- Weekly aggregation and merge are done later in the notebook.
