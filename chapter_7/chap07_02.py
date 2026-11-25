# Databricks notebook source
# Listing 7.2: Iterating over a list of tables to create and load each in the lakehouse
# Run after chap07_01.py, which defines jdbc_url and connection_props.

tables = [
    # (source_table, target_table, partition_key)
    ("dbo.sales_fact", "sales.bronze.sales_fact", "sale_id"),
    ("dbo.customer",   "sales.bronze.customer",   "customer_id"),
    ("dbo.product",    "sales.bronze.product",    "product_id"),
    # ... add more tables here
]

for src_table, tgt_table, key in tables:
    bounds = (
        spark.read.format("jdbc")
        .option("url", jdbc_url)
        .option("dbtable", f"(SELECT MIN({key}) AS min_id, MAX({key}) AS max_id FROM {src_table}) t")
        .options(**connection_props)
        .load()
        .collect()[0]
    )
    df = (
        spark.read
        .format("jdbc")
        .option("url", jdbc_url)
        .option("dbtable", src_table)
        .option("partitionColumn", key)
        .option("lowerBound", int(bounds["min_id"]))
        .option("upperBound", int(bounds["max_id"]))
        .option("numPartitions", 16)
        .option("fetchsize", 10000)
        .options(**connection_props)
        .load()
    )

    (df.write
        .format("delta")
        .mode("overwrite")
        .saveAsTable(tgt_table))
    row_count = spark.table(tgt_table).count()  # count the Delta table, not the JDBC source
    print(f"Loaded {src_table} -> {tgt_table}: {row_count:,} rows")
