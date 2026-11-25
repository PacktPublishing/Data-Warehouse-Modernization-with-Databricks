# Chapter 10: refinement pipeline bundle

`resources/chap10_02.yml` is the bundle configuration printed in the chapter. It defines the
`iot_refinement` pipeline (`src/iot_refinement.sql`) and three jobs that run it in different ways:
hourly, continuously, and whenever `main.iot.bronze_sensor_events` changes.

The pipeline expects the bronze table `main.iot.bronze_sensor_events`, with at least `device_id` and
`event_time` columns, to exist. It writes `silver_sensor_readings` and `gold_device_hourly` to `main.iot`.

As the chapter says, in practice you deploy only one of the three jobs. Delete the two you don't want
from `resources/chap10_02.yml` before deploying, because the continuous and table-update jobs start
unpaused.

```
databricks bundle validate
databricks bundle deploy
```
