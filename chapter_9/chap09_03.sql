WITH wh_cost AS (   -- billed $ per warehouse per day
  SELECT u.usage_metadata.warehouse_id AS warehouse_id, u.usage_date,
         SUM(u.usage_quantity * lp.pricing.effective_list.default) AS day_cost
  FROM system.billing.usage u
  JOIN system.billing.list_prices lp
    ON lp.sku_name = u.sku_name
   AND u.usage_end_time >= lp.price_start_time
   AND (lp.price_end_time IS NULL OR u.usage_end_time < lp.price_end_time)
  WHERE u.usage_metadata.warehouse_id IS NOT NULL
  GROUP BY 1, 2),
q AS (   -- each warehouse statement's share of its warehouse-day, by duration
  SELECT compute.warehouse_id AS warehouse_id, statement_id, executed_by,
         CAST(start_time AS DATE) AS d, total_duration_ms,
         total_duration_ms / SUM(total_duration_ms)
           OVER (PARTITION BY compute.warehouse_id, CAST(start_time AS DATE)) AS share
  FROM system.query.history
  WHERE compute.type = 'WAREHOUSE')
-- duration-based shares spread idle auto-stop time across whoever ran queries
SELECT q.executed_by, q.statement_id,
       q.share * c.day_cost AS allocated_cost
FROM q JOIN wh_cost c
  ON c.warehouse_id = q.warehouse_id AND c.usage_date = q.d
ORDER BY allocated_cost DESC;
