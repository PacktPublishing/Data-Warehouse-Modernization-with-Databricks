SELECT *
FROM ai_forecast(
  TABLE(SELECT sale_date, store_id, units_sold
        FROM curated.sales.daily_store_sales),
  horizon   => DATE'2027-03-31',
  time_col  => 'sale_date',
  value_col => 'units_sold',
  group_col => 'store_id'
);
