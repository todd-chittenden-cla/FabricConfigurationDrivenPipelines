/*
This script will populate the Main Control Table in the Fabric SQL database
with TWO records: one for a FULL load and one for a DELTA load of the listed table.
*/

/* Some variables that are table specific: */
DECLARE @Source     		NVARCHAR(20)	= 'PowerBIDW'; /* Options: PowerBIDW | <something to be added later>  */
DECLARE @SourceSchemaName	NVARCHAR(100)   = 'dbo';
DECLARE @SourceTableName	NVARCHAR(100)   = 'BusinessUnit';
DECLARE @KeyColumns			NVARCHAR(200)	= '["BusinessUnitCode"]'; /* Comma delimited if multiple keys ["SysRowID"] */		

DECLARE @SinkSchemaName		NVARCHAR(100)	= @SourceSchemaName; /* Options: Erp, EpicorViews, EpicorERPEOM */
DECLARE @SinkTableName		NVARCHAR(100)	= @SourceTableName;  /* or something else if needed */

/* Some CONSTANT values */
DECLARE @ServerGUID					NVARCHAR(100)	= 'nv664whn3zsefbhnfzmjkcyr6a-5rrjaoi5pncetjuevmvlm6ucnq' /* This is the connection string GUID only, minus the .datawarehouse.fabric.microsoft.com */
DECLARE @WorkspaceID				NVARCHAR(100)	= '399062ec-7b1d-4944-a684-ab2ab67a826c' /* From the browser */
DECLARE @WarehouseConnectionID		NVARCHAR(100)	= '7806a8f9-3815-461d-9a1b-d7a2f1572d29' /* From Connections and Settings */
--DECLARE @LakehouseConnectionID		NVARCHAR(100)	= '78298e55-69f2-4ef9-ae37-c814a191db6e'

/* Some variables that are based on the source system: */
DECLARE @SourceConnectionID NVARCHAR(100)	= CASE @Source  WHEN 'PowerBIDW'	THEN '58b0aa11-7295-4767-9912-8cff922e78a' /* can be gotten from the browser */
							
															--WHEN 'CA'			THEN 'eac793e4-6355-4e84-b737-b590fcd6a150'
															--WHEN 'VSS'		THEN '5e4389ee-d72e-4842-9082-9741b37a7941'
															--WHEN 'WH_EV'		THEN '97c62e10-a578-4bca-b56e-3ae78b400bb6'
															--WHEN 'WH_EOM'		THEN '97c62e10-a578-4bca-b56e-3ae78b400bb6'
															ELSE 'BAR'
															END;

DECLARE @DatabaseName	NVARCHAR(100)		= CASE @Source	WHEN 'PowerBIDW'		THEN 'PowerBIDW' /* From the Source Server */
															--WHEN 'CA'		THEN 'EpicorERP'
															--WHEN 'VSS'	THEN 'Kinetic'	
															--WHEN 'WH_EV'	THEN 'EpicorViews'
															--WHEN 'WH_EOM'	THEN 'EpicorERPEOM'
															ELSE 'BAR'
															END

DECLARE @WarehouseID		NVARCHAR(100)	= CASE @Source	WHEN 'PowerBIDW'	THEN '58b0aa11-7295-4767-9912-8cff922e78a3'
															--WHEN 'CA'			THEN 'ebe19a2f-7bd7-475e-a9a7-a1d23573c4ee'
															--WHEN 'VSS'		THEN 'bd3bdc26-a156-4070-a1fb-811b800f332b'
															--WHEN 'WH_EV'		THEN 'fc120587-9da2-44aa-822a-44cd520f4a4d'
															--WHEN 'WH_EOM'		THEN 'fc120587-9da2-44aa-822a-44cd520f4a4d'
															ELSE 'BAR'
															END

DECLARE @WarehouseName		NVARCHAR(100)	= CASE @Source	WHEN 'PowerBIDW'	THEN 'wh_Silver_PowerBIDW'
															--WHEN 'CA'			THEN 'wh_Silver_Colt_CA'
															--WHEN 'VSS'		THEN 'wh_Silver_Colt_VSS'
															--WHEN 'WH_EV'		THEN 'wh_Silver_Colt_WH'
															--WHEN 'WH_EOM'		THEN 'wh_Silver_Colt_WH'
															ELSE 'BAR'
															END

--DECLARE @LakehouseID		NVARCHAR(100)	=	CASE @Source	WHEN 'PowerBIDW'		THEN '41aaa54d-e665-40d5-89f8-886ac3197a64'
--																WHEN 'CA'		THEN 'b6633a3b-e937-4402-856a-d0758cb3f459'
--																WHEN 'VSS'		THEN '11a84c9b-8b7e-4dce-8839-987df176e635' 
--																WHEN 'WH_EV'	THEN '41aaa54d-e665-40d5-89f8-886ac3197a64'
--																WHEN 'WH_EOM'	THEN '41aaa54d-e665-40d5-89f8-886ac3197a64'
--																ELSE 'BAR'
--																END

DECLARE @ScheduleIDFULL		NVARCHAR(100)	=	'N/A' /*	CASE @SourceSystem	WHEN 'WH'		THEN '6bcfc25e-daae-477a-969b-204507b5b4cc'
																	WHEN 'CA'		THEN 'af32c5ee-6272-4cab-99cd-e95e9459c0c3'
																	WHEN 'VSS'		THEN 'Foo'
																	WHEN 'WH_EV'	THEN 'Foo'
																	WHEN 'WH_EOM'	THEN 'Foo'
																	ELSE 'BAR'
																	END */

DECLARE @ScheduleIDDELTA	NVARCHAR(100)	=	'N/A' /*	CASE @SourceSystem	WHEN 'WH'		THEN '5709219a-7f83-4668-87e1-d7af5243839d'
																	WHEN 'CA'		THEN '2139d53a-b71b-4537-9e44-441f4b9064cd'
																	WHEN 'VSS'		THEN 'Foo'
																	WHEN 'WH_EV'	THEN 'Foo'
																	WHEN 'WH_EOM'	THEN 'Foo'
																	ELSE 'BAR'
																	END */


DECLARE @WatermarkStart	NVARCHAR(100)		=	CASE @Source	WHEN 'PowerBIDW'	THEN '01/01/2025'
																--WHEN 'CA'			THEN '0x0000000075DB1A14'
																--WHEN 'VSS'		THEN '0x0000000000000000'
																--WHEN 'WH_EV'		THEN '0x0000000000000000'
																--WHEN 'WH_EOM'		THEN '0x0000000000000000'
																ELSE 'BAR'
																END

DECLARE @WatermarkColumnName NVARCHAR(20)	=	CASE @Source	WHEN 'PowerBIDW'	THEN 'LastUpdateDateTime'
																--WHEN 'CA'			THEN '0x0000000075DB1A14'
																--WHEN 'VSS'		THEN '0x0000000000000000'
																--WHEN 'WH_EV'		THEN '0x0000000000000000'
																--WHEN 'WH_EOM'		THEN '0x0000000000000000'
																ELSE 'BAR'
																END

DECLARE @WatermarkColumnType NVARCHAR(20)	=	CASE @Source	WHEN 'PowerBIDW'	THEN 'DATETIME'
																--WHEN 'CA'			THEN '0x0000000075DB1A14'
																--WHEN 'VSS'		THEN '0x0000000000000000'
																--WHEN 'WH_EV'		THEN '0x0000000000000000'
																--WHEN 'WH_EOM'		THEN '0x0000000000000000'
																ELSE 'BAR'
																END
INSERT INTO [dbo].[MainControlTable] (						
	[SourceObjectSettings],
	[SourceConnectionSettings],		
	[CopySourceSettings],			
	[SinkObjectSettings],			
	[SinkConnectionSettings],		
	[CopySinkSettings],			
	--[MergeProcedureSettings],		
	[CopyActivitySettings],			
	[TopLevelPipelineName],			
	[ScheduleSettings],					
	[DataLoadingBehaviorSettings],	
	[TaskId],						
	[CopyEnabled]
	)

/* Full Load row: */
SELECT	
	[SourceObjectSettings]			= '{ "Source": "' + @Source + '", "schema": "' + @SourceSchemaName + '", "table": "' + @SourceTableName + '" }',
	[SourceConnectionSettings]		= '{ "sourceConnectionID": "' + @SourceConnectionID + '", "databaseName": "' + @DatabaseName + '" }',
	[CopySourceSettings]			= '{ "partitionOption": "None", "sqlReaderQuery": null, "partitionLowerBound": null, "partitionUpperBound": null, "partitionColumnName": null, "partitionNames": null }',
	[SinkObjectSettings]			= '{ "schema": "' + @SinkSchemaName + '", "table":"' + @SinkTableName + '" }',
	[SinkConnectionSettings]		= '{ "warehouseConnectionID": "' + @WarehouseConnectionID + '", "workspaceID": "' + @WorkspaceID + '", "warehouseID": "' + @WarehouseID + '", "sqlConnectionString": "' + @ServerGUID + '.datawarehouse.fabric.microsoft.com", "databaseName": "' + @WarehouseName + '" }',
	[CopySinkSettings]				= '{ "preCopyOption": "TRUNCATE", "preCopyScript":"IF OBJECT_ID(''' + @SinkSchemaName + '.' + @SinkTableName + ''', ''U'') IS NOT NULL TRUNCATE TABLE ' + @SinkSchemaName + '.' + @SinkTableName + ';", "tableOption":"autoCreate", "writeBehavior": "insert"}',
	--[MergeProcedureSettings]		= 'Not needed for FullLoad',
	[CopyActivitySettings]			= '{ "translator": null }',
	[TopLevelPipelineName]			= 'Top Level Full',
	[ScheduleSettings]				= '{ "scheduleID": "' + @ScheduleIDFULL + '" }',
	[DataLoadingBehaviorSettings]	= '{ "dataLoadingBehavior": "FullLoad" }	',
	[TaskId]						= 0,
	[CopyEnabled]					= 1

UNION
/* Delta Load row: */
	SELECT	
	[SourceObjectSettings]			= '{ "Source": "' + @Source + '", "schema": "' + @SourceSchemaName + '", "table": "' + @SourceTableName + '" }',
	[SourceConnectionSettings]		= '{ "sourceConnectionID": "' + @SourceConnectionID + '", "databaseName": "' + @DatabaseName + '" }',
	[CopySourceSettings]			= '{ "partitionOption": "None", "sqlReaderQuery": null, "partitionLowerBound": null, "partitionUpperBound": null, "partitionColumnName": null, "partitionNames": null }',
	[SinkObjectSettings]			= '{ "schema": "' + @SinkSchemaName + '", "table":"' + @SinkTableName + '" }',
	[SinkConnectionSettings]		= '{ "workspaceID": "' + @WorkspaceID + '", "warehouseID": "' + @WarehouseID + '", "sqlConnectionString": "' + @ServerGUID + '.datawarehouse.fabric.microsoft.com", "databaseName": "' + @WarehouseName + '" }',
	[CopySinkSettings]				= '{ "preCopyScript": null, "tableOption": null, "writeBehavior": "Upsert", "upsertSettings": { "keys": ' + @KeyColumns + ' , "interimSchemaName": "" } }',
	--[CopySinkSettings]				= '{ "tableOption": "OverwriteSchema", "waitTime": "300" }',
	--[MergeProcedureSettings]		= '{ "mergeConnectionID": "' + @WarehouseConnectionID + '", "workspaceID": "' + @WorkspaceID + '", "warehouseID": "' + @WarehouseID + '", "sqlConnectionString": "' + @ServerGUID + '.datawarehouse.fabric.microsoft.com", "databaseName": "' + @WarehouseName + '",  "storedProcedure": "' + @SinkSchemaName + '.MERGE_'  + @SourceTableName + '" }',
	[CopyActivitySettings]			= '{ "translator": null }',
	[TopLevelPipelineName]			= 'Top Level Delta',
	[ScheduleSettings]				= '{ "scheduleID": "' + @ScheduleIDDELTA + '" }',
	[DataLoadingBehaviorSettings]	= '{ "dataLoadingBehavior": "DeltaLoad", "watermarkColumnName": "' + @WatermarkColumnName + '","watermarkColumnType": "' + @WatermarkColumnType + '", "watermarkColumnStartValue": "' + @WatermarkStart + '" }',
	[TaskId]						= 0,
	[CopyEnabled]					= 1



