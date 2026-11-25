SELECT
  date_trunc('WEEK', start_time)  AS usage_week,
  client_application,
  COUNT(DISTINCT executed_by)     AS active_users,
  COUNT(*)                        AS queries
FROM system.query.history
WHERE start_time >= current_date() - INTERVAL 90 DAYS
  AND execution_status = 'FINISHED'
  AND query_source.job_info.job_id IS NULL
GROUP BY ALL
ORDER BY usage_week, active_users DESC;
