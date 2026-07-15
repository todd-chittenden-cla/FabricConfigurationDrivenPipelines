# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "7757cf9d-9d5d-4446-af76-0c44d18fe317",
# META       "default_lakehouse_name": "lh_Bronze_PowerBIDW",
# META       "default_lakehouse_workspace_id": "399062ec-7b1d-4944-a684-ab2ab67a826c",
# META       "known_lakehouses": [
# META         {
# META           "id": "7757cf9d-9d5d-4446-af76-0c44d18fe317"
# META         }
# META       ]
# META     },
# META     "warehouse": {
# META       "known_warehouses": []
# META     }
# META   }
# META }

# CELL ********************

# Welcome to your new notebook
# Type here in the cell editor to add code!

backup_tables = spark.sql("""
    SHOW TABLES IN NetSmart
""").filter("tableName LIKE '%_backup_%'")

display(backup_tables)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

for row in backup_tables.collect():
    spark.sql(f"DROP TABLE NetSmart.`{row.tableName}`")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
