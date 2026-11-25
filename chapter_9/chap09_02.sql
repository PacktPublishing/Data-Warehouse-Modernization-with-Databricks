SELECT
  CASE
    WHEN u.custom_tags['cost_center'] IS NULL
      OR u.custom_tags['cost_center'] = ''  THEN 'Unallocated'
    WHEN u.custom_tags['cost_center'] IN ('CC-1001','CC-1002') THEN 'Data Platform'
    WHEN u.custom_tags['cost_center'] = 'CC-2001'             THEN 'Analytics'
    ELSE u.custom_tags['cost_center']
  END                                                        AS cost_bucket,
  date_trunc('MONTH', u.usage_date)                          AS usage_month,
  SUM(u.usage_quantity * lp.pricing.effective_list.default)  AS est_cost
FROM system.billing.usage AS u
JOIN system.billing.list_prices AS lp
  ON  lp.sku_name = u.sku_name
  AND u.usage_end_time >= lp.price_start_time
  AND (lp.price_end_time IS NULL OR u.usage_end_time < lp.price_end_time)
WHERE u.usage_date >= '2026-01-01'
GROUP BY 1, 2
ORDER BY usage_month, est_cost DESC;
