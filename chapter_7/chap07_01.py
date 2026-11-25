# Databricks notebook source
# Listing 7.1: Reading from a source SQL Server table over JDBC into a Spark DataFrame
# Databricks Runtime already includes the SQL Server JDBC driver. Create a "migration" secret scope holding src_user and src_password first.

# Configure the source connection
jdbc_url = (
    "jdbc:sqlserver://source-server.company.com:1433;"
    # trustServerCertificate=true skips certificate validation (lab use only)
    "database=warehouse;encrypt=true;trustServerCertificate=true"
)
connection_props = {
    "user":     dbutils.secrets.get("migration", "src_user"),
    "password": dbutils.secrets.get("migration", "src_password"),
    "driver":   "com.microsoft.sqlserver.jdbc.SQLServerDriver",
}

# Fetch the actual MIN and MAX sale_id to avoid skewed partitions
bounds = (
    spark.read.format("jdbc")
    .option("url", jdbc_url)
    .option("dbtable", "(SELECT MIN(sale_id) AS min_id, MAX(sale_id) AS max_id FROM dbo.sales_fact) t")
    .options(**connection_props)
    .load()
    .collect()[0]
)
lower_bound = int(bounds["min_id"])
upper_bound = int(bounds["max_id"])

# Read with partitioning for parallelism on large tables
df = (
    spark.read
    .format("jdbc")
    .option("url", jdbc_url)
    .option("dbtable", "dbo.sales_fact")
    .option("partitionColumn", "sale_id")
    .option("lowerBound", lower_bound)
    .option("upperBound", upper_bound)
    .option("numPartitions", 16)
    .option("fetchsize", 10000)
    .options(**connection_props)
    .load()
)
