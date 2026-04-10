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
   URL: https://archive-api.open-meteo.com/v1/archive?latitude=23.8103&longitude=90.4125&start_date=2023-01-01&end_date=2024-12-31&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,shortwave_radiation_sum&timezone=Asia/Dhaka
   File: weather_openmeteo_dhaka_2023-01-01_2024-12-31.json

Notes:
- This script only automates the weather pull.
- The cholera disease source is intentionally left manual for now because the
  public data sources are dashboard/bulletin-oriented rather than one stable,
  clean weekly API like flu or dengue.
