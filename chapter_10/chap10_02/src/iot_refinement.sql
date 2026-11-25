-- Refinement pipeline for chapter 10: bronze -> silver -> gold.
-- Reads the raw device events in main.iot.bronze_sensor_events (device_id, event_time, ...).

-- Silver: cleansed readings, incrementally processed as new bronze rows arrive.
CREATE OR REFRESH STREAMING TABLE silver_sensor_readings (
  CONSTRAINT valid_reading EXPECT (device_id IS NOT NULL AND event_time IS NOT NULL) ON VIOLATION DROP ROW
)
COMMENT 'Cleansed device readings refined from bronze'
AS SELECT *
FROM STREAM(main.iot.bronze_sensor_events);

-- Gold: readings per device per hour, recomputed incrementally on each update.
CREATE OR REFRESH MATERIALIZED VIEW gold_device_hourly
COMMENT 'Readings per device per hour'
AS SELECT
  device_id,
  date_trunc('HOUR', event_time) AS event_hour,
  COUNT(*)                       AS readings
FROM silver_sensor_readings
GROUP BY ALL;
