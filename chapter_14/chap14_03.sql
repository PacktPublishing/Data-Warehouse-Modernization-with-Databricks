WITH q AS (
  SELECT compute.warehouse_id AS warehouse_id,
         from_utc_timestamp(start_time, 'America/New_York') AS start_time,
         total_duration_ms
  FROM system.query.history
  WHERE start_time >= current_date() - INTERVAL 30 DAYS
    AND execution_status = 'FINISHED'
    AND compute.warehouse_id IS NOT NULL
    AND NOT from_result_cache
),
latency AS (
  SELECT
    to_date(start_time)                                   AS usage_date,
    warehouse_id,
    COUNT(*)                                              AS queries,
    ROUND(percentile(total_duration_ms, 0.50) / 1000, 2)  AS p50_latency_s,
    ROUND(percentile(total_duration_ms, 0.95) / 1000, 2)  AS p95_latency_s
  FROM q
  GROUP BY ALL
),
throughput AS (
  SELECT to_date(query_minute) AS usage_date, warehouse_id,
         MAX(queries_per_minute) AS peak_queries_per_minute
  FROM (
    SELECT warehouse_id, date_trunc('MINUTE', start_time) AS query_minute,
           COUNT(*) AS queries_per_minute
    FROM q
    GROUP BY ALL
  )
  GROUP BY ALL
)
SELECT l.*, t.peak_queries_per_minute
FROM latency AS l
JOIN throughput AS t USING (usage_date, warehouse_id)
ORDER BY usage_date, queries DESC;
