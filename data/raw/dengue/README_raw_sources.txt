Raw data files downloaded by scripts/download_dengue.sh

1) Disease signal
   Source: data.gov.sg / MOH
   Dataset: Weekly Number of Dengue and Dengue Haemorrhagic Fever Cases
   Dataset ID: d_ac1eecf0886ff0bceefbc51556247015
   URL: https://data.gov.sg/api/action/datastore_search?resource_id=d_ac1eecf0886ff0bceefbc51556247015&limit=2000
   File: dengue_singapore_weekly_2014_2018.json

2) Weather
   Source: Open-Meteo Historical Weather API
   URL: https://archive-api.open-meteo.com/v1/archive?latitude=1.3521&longitude=103.8198&start_date=2014-01-01&end_date=2018-12-31&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,shortwave_radiation_sum&timezone=Asia/Singapore
   File: weather_openmeteo_singapore_2014-01-01_2018-12-31.json

Run notes:
- Re-run safely any time.
- Use FORCE=1 ./scripts/download_dengue.sh to overwrite.
- Disease data is weekly.
- Weather data is daily and will be aggregated in the notebook.
