/*

Purpose: This project contains various scripts to interface with the data in the Pipeline Control SQL database.

The Pipeline Control database is a SQL Database hosted in Fabric. It has all the features and functionality
of an Azure SQL database, but is native to Fabric. This makes it easier to access and interact with.

The database itself is actually named "PipelineControl-<with some guid>". Microsoft adds
the GUID at the end of the name to make it unique across ALL of Fabric. This was a requirement during the Microsoft's development
and public preview stages of this object and I am not sure if they ever solved for the fact that it need
only be unique across the Fabric WORKSPACE, not the entire world. Go figure.

The database is also exposed via the Workspace's SQL Analytic Endpoint alongside all Warehouses and Lakehouses
in the Workspace. Here, the GUID is dropped from the name. Also, functionality is limited when interfacing with
this database via the SQL Analytic Endpoint. For example, no DDL (Data Definition Language) statements are allowed, 
and NVARCHAR columns are all exposed as VARCHAR(8000) regardless of defined length.

The Top, Middle, and Bottom level pipelines use data in this database and interact with it via the Azure SQL enpoint
(NOT the SQL Analytic endpoint). 

Shared Queries in this Project:
00 Read Me: (this file)

01 CREATE Tables
	This contains three CREATE TABLE statements. Each of these tables is basially the exact same schema, with minor differences. 
	* Main Control Table
	* Main Control Table DEBUG (Does not have IDENTITY specified on the Id column)
	* Main Control Table BACKUP (Does not have the IDENTITY specified on the Id column. Includes a SaveDate column)
	

02 BACKUP Main Control Table
	This is a Stored Procedure that backs up the Main Control Table. If any backup data already exists for the 
	same DAY, that data is deleted and re-added.

03 COPY Main Control Table for DEBUG
	This is a Stored Procedure that copies a single row from the Main Control Table to the DEBUG table to be
	used when the DEBUG parameter is set. It accepts [Id] as an input parameter. If the row already exists in the DEBUG
	table, it is first deleted. Some columns are skipped or otherwise overridden during the copy:
	* [CopyEnabled]				Set to 1
	* [LastRunDateTime]			Set to NULL

04 COPY Main Control Table for PROD
	This is a Stored Procedure that copies a row from the DEBUG table back to the Main Control Table.
	The development process should be to copy a row over to the DEBUG table, run the DEBUG pipelines to verify results,
	make appropriate changes until the run is successful, then copy the row back to the Production table. This is
	a poor man's source control. The procedure accepts [Id] as an input parameter, and also runs the BACKUP operation
	(see above) before copying the data over. Some columns are skipped while copying back:  
	* [TopLevelPipelineName] ignored.
	* [ScheduleSettings] 	ignored
	* [CopyEnabled] 		ignored
	* [LastRunDateTime] 	ignored


05 CREATE PROC Update Watermark Column Value
	This is a stored procedure that updates either the LastRunDateTime, the WatermarkColumnValue, or both.
	* Immediately after a Full Load, only the LastRunDateTime
	* As the last step of a Full Load, only the WatermarkColumnValue for the complimentary Delta row.
	* After a Delta load: both

06 CREATE PROC Update Watermark Column DEBUG
	(Same as above, but targets the MainControlTable_DEBUG)



10 CREATE PROC NEW Control Row
	This is a stored procedure that handles populating a new Control Row.
	This proceudre should be reviewed and edited to update the various lakehouse GUIDs and Connection GUIDs
	before putting it to use.
		This script generates and inserts TWO rows of data into the Main Control table for any one source table:
	one for a FULL load and one for a DELTA load. There are a few key variables that should be set at the begining
	of the script:

	This procedure has multiple input parameters:
	* @Source				Code or phrase representing the source system 
	* @SourceSchemaName		Typically "dbo" but may differ depending on the database
	* @SourceTableName		Self explanatory
	* @KeyColumns			Comma Separated list ["SysRowID"] or ["ID, Name"]
    * @WatermarkColumnName  Hopefully something like [LastUpdateDateTime] 
    * @WatermarkColumnType  SUPPORTED: DATETIME | TIMESTAMP | ROWVERSION | INT | BIGINT
    * @WatermarkStart       Example: 1/01/2025 | 0

	* @SinkSchemaName		Typcially the same as the Source Schema. May be different if all sources dump to one single
							Lakehouse that uses schema to differentiate.
	* @SinkTableName		Typically the same as the Source Table.	


	Based on the Source System, various other variables are set. In the end, these variables are used during the
	two INSERT statements that follow. 

	IMPORTANT: Edit the various GUID values for Connection ID, Workspace ID, Lakehouse ID and Name, etc. to match
				your environment.

40 New Control Rows
	This script runs the procedure above twice to generate a total of four rows (2 FULL, 2 DELTA) in the MainControlTable.

50 Explanation of Pipeline Tasks
	English description of what each task does in each pipeline.

60 Nuances of Watermarks
	What to look for.

70 Using the DEBUG Path
	Sample code and instructions for using the pipelines in DEBUG mode.

80 Known Limitations
	(Self-explanatory. If there were any UN-known limitations, then they would be, by definition, KNOWN!)


*/