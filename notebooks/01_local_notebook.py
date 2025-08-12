# Databricks notebook source
# COMMAND ----------
print("Hello from a local notebook via DAB!")

# COMMAND ----------
from pyspark.sql import functions as F

df = spark.range(0, 5).toDF("id").withColumn("ts", F.current_timestamp())
display(df)
