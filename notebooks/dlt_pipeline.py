# Databricks notebook source
# COMMAND ----------
import dlt
from pyspark.sql import functions as F

# COMMAND ----------
@dlt.table
def bronze_numbers():
    return spark.range(0, 10).withColumn("ts", F.current_timestamp())

# COMMAND ----------
@dlt.table
def silver_numbers():
    return dlt.read("bronze_numbers").withColumn("double_id", F.col("id") * 2)
