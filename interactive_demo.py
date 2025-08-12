# Databricks notebook source
# MAGIC %md
# MAGIC # Interactive Databricks Demo
# MAGIC 
# MAGIC Use **Ctrl+Shift+P** → "Databricks: Run Cell" to run individual cells

# COMMAND ----------
# MAGIC %md 
# MAGIC ## Test Connection

# COMMAND ----------
print("Testing Spark connection...")
print(f"Spark version: {spark.version}")
print(f"Spark context: {spark.sparkContext}")

# COMMAND ----------
# MAGIC %md
# MAGIC ## Create Sample Data

# COMMAND ----------
# Create sample data
from pyspark.sql import functions as F
from pyspark.sql.types import StructType, StructField, StringType, IntegerType

data = [
    ("Alice", 25, "Engineer"),
    ("Bob", 30, "Manager"), 
    ("Charlie", 35, "Analyst"),
    ("Diana", 28, "Designer")
]

schema = StructType([
    StructField("name", StringType(), True),
    StructField("age", IntegerType(), True),
    StructField("role", StringType(), True)
])

df = spark.createDataFrame(data, schema)
print("DataFrame created successfully!")
df.show()

# COMMAND ----------
# MAGIC %md
# MAGIC ## Data Transformations

# COMMAND ----------
# Add transformations
df_transformed = df.withColumn("age_group", 
    F.when(F.col("age") < 30, "Young")
     .otherwise("Experienced")
)

print("DataFrame with age groups:")
df_transformed.show()

print("Count by age group:")
df_transformed.groupBy("age_group").count().show()

# COMMAND ----------
# MAGIC %md
# MAGIC ## Try Display Function

# COMMAND ----------
# Try display function (if available)
try:
    display(df_transformed)
    print("✅ display() function worked!")
except NameError:
    print("ℹ️  display() function not available - using show() instead")
    df_transformed.show()

# COMMAND ----------
# MAGIC %md
# MAGIC ## File Operations

# COMMAND ----------
# Write and read data
output_path = "/tmp/demo_data.parquet"

df_transformed.write.mode("overwrite").parquet(output_path)
print(f"✅ Data written to: {output_path}")

# Read it back
df_read = spark.read.parquet(output_path)
print("✅ Data read back from DBFS:")
df_read.show()

# COMMAND ----------
# MAGIC %md
# MAGIC ## Delta Table Example

# COMMAND ----------
# Try Delta Lake
try:
    delta_path = "/tmp/demo_delta_table"
    
    df_transformed.write.format("delta").mode("overwrite").save(delta_path)
    print(f"✅ Delta table written to: {delta_path}")
    
    df_delta = spark.read.format("delta").load(delta_path)
    print("✅ Delta table contents:")
    df_delta.show()
    
except Exception as e:
    print(f"ℹ️  Delta Lake error: {e}")
    print("This might be expected if Delta is not configured")
