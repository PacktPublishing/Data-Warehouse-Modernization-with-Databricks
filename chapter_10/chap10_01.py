# Databricks notebook source
# Read the raw device events landing in the bronze table as a stream
bronze = spark.readStream.table("main.iot.bronze_sensor_events")
silver = (
    bronze
    # Track event time and wait up to 10 minutes for late-arriving readings
    .withWatermark("event_time", "10 minutes")
    # Collapse duplicate deliveries of the same reading; device_id plus event_time is its key
    .dropDuplicates(["device_id", "event_time"])
)
# Write the cleansed, de-duplicated stream to the silver table
query = (silver.writeStream
    .option("checkpointLocation", "/Volumes/main/iot/checkpoints/silver_sensor_events")
    .trigger(processingTime="1 minute")
    .toTable("main.iot.silver_sensor_events"))
