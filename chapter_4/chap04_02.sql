CREATE CATALOG IF NOT EXISTS raw COMMENT 'Bronze - raw ingested data'; 
CREATE CATALOG IF NOT EXISTS curated COMMENT 'Silver - cleansed, conformed';
CREATE CATALOG IF NOT EXISTS analytics COMMENT 'Gold - business-ready marts'; 

CREATE SCHEMA IF NOT EXISTS curated.sales; 
CREATE SCHEMA IF NOT EXISTS curated.finance; 
CREATE SCHEMA IF NOT EXISTS curated.customer; 
CREATE SCHEMA IF NOT EXISTS curated.security;
CREATE SCHEMA IF NOT EXISTS curated.support;
CREATE SCHEMA IF NOT EXISTS analytics.sales;

GRANT USE CATALOG ON CATALOG analytics              TO `analysts`; 
GRANT USE SCHEMA  ON SCHEMA  analytics.sales        TO `analysts`; 
GRANT SELECT      ON SCHEMA  analytics.sales        TO `analysts`; 

CREATE TABLE IF NOT EXISTS curated.sales.dim_customer (
  customer_id     BIGINT,
  customer_name   STRING,
  customer_email  STRING,
  country         STRING
);

CREATE TABLE IF NOT EXISTS analytics.sales.daily_summary (
  sales_date    DATE,
  category      STRING,
  txn_count     BIGINT,
  total_amount  DECIMAL(18,2)
);

CREATE TABLE IF NOT EXISTS curated.support.customer_feedback (
  feedback_id    BIGINT,
  feedback_text  STRING,
  event_date     DATE
);

CREATE TABLE IF NOT EXISTS curated.support.orders (
  order_id     BIGINT,
  description  STRING
);

CREATE TABLE IF NOT EXISTS analytics.sales.orders (
  order_id          BIGINT,
  account_id        STRING,
  product_id        STRING,
  transaction_date  DATE,
  amount            DECIMAL(18,2)
)
PARTITIONED BY (transaction_date);
