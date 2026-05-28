# FabricConfigurationDrivenPipelines
## Scope
Fabric pipelines using Configuration driven pipelines. The architecture for this solution came from classic Azure Data Factory sizard for "Meta data driven pipeline" and has been adopted for Fabric.

## Description
This repository is for the Fabric Configuration Driven Pipelines. The solution consists of the following items:
* Three Fabric Data Factory Pipelines
* Two Fabric Lakehouse
* A Fabric SQL Server database
* Various Connectons and Gateways

The SQL Database (PipelineControl)contains a configuration table (dbo.MainControlTable). This holds configuration entries for loading source tables, two rows per source table: one for a FULL load and one for a DELTA load. Most of the columns contain JSON data.

The Top Level pipeline is responsible for collecting all the rows that will be run and dividing that set into batches, base on the pipeline parameter "MaxNumberOfConcurrentTables". It then calls the Middle Level Pipeline for each batch of tables. The Middle Level then passes the batch down to the Bottom Level in an array of tables to be loaded. This is where all the magic happens. There are tow main paths (Cases) to the SWITCH:
Full Load:
* Do a SELECT * from the table in question, and save it to the lakehouse (per the configuration settings).
* Record the LastRunDateTime for the table (via a stored procedure).
* Refresh the SQL Analytic Endpoint
* Query the table for the highest watermark value
* Query the Main Control Table for the correspoonding Delta Row Id
* Update the Main Control Table's Delta Row with latest watermark value.
Delta Load:
* Query the source table with a filter on the watermark column (value and column name come from the Main Control Table).
* 
