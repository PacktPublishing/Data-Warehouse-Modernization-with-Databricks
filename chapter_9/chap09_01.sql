SELECT
  date_trunc('MONTH', u.usage_date)                          AS usage_month,
  u.billing_origin_product                                   AS product,
  SUM(u.usage_quantity * lp.pricing.effective_list.default)  AS est_cost,
  lp.currency_code
FROM system.billing.usage AS u
JOIN system.billing.list_prices AS lp
  ON  lp.sku_name = u.sku_name
  AND u.usage_end_time >= lp.price_start_time
  AND (lp.price_end_time IS NULL OR u.usage_end_time < lp.price_end_time)
WHERE u.usage_date >= '2026-01-01'
GROUP BY 1, 2, 4
ORDER BY usage_month, est_cost DESC;
