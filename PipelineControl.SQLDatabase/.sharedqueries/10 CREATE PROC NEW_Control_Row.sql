CREATE OR ALTER PROCEDURE dbo.CREATE_NEW_Control_Row
(
/* Some Parameters that are table specific: */
    @Source     		    NVARCHAR(20),       /* Options: PowerBIDW | IMDB. Your options will vary.  */
    @SourceSchemaName	    NVARCHAR(100),      /* Typically 'dbo' but depends on the Source */
    @SourceTableName	    NVARCHAR(100), 		/* Self-explanatory */
    @KeyColumns			    NVARCHAR(200),	    /* Comma Separated list ["SysRowID"] or ["ID, Name"] */	
    @WatermarkColumnName    NVARCHAR(200),	    /* Hopefully something like [LastUpdateDateTime] */
    @WatermarkColumnType    NVARCHAR(100),      /* SUPPORTED: DATETIME | TIMESTAMP | ROWVERSION | INT | BIGINT */
    @WatermarkStart         NVARCHAR(100),      /* Example: 1/01/2025 | 0 */
    @SinkSchemaName		    NVARCHAR(100),	    /* Typically the same as the SourceSchemaName */
    @SinkTableName		    NVARCHAR(100)	    /* Typically the same as the SourceTableName */
)
AS

/* **************************************
Version History

Version     Date            By                  Notes
=======     ====            ==                  =====
1.0.00      02/13/2026      Todd Chittenden     Initial Version
1.0.01		05/18/2026		...					Fixing issues.

Notes:
Before creating this procedure, the relevant GUIDs and object names need to be populated.

*************************************** */

SET NOCOUNT ON;



/* Some CONSTANT values that will need to be edited: */
DECLARE @ServerGUID					NVARCHAR(100)	= 'nv664whn3zsefbhnfzmjkcyr6a-5rrjaoi5pncetjuevmvlm6ucnq'; /* This is the connection string GUID only, minus the .datawarehouse.fabric.microsoft.com */
DECLARE @WorkspaceID				NVARCHAR(100)	= '399062ec-7b1d-4944-a684-ab2ab67a826c'; /* From the browser */
DECLARE @LakehouseConnectionID		NVARCHAR(100)	= '758f4778-cc01-43dd-80a2-3c380ff06741'; /* From Connections and Gateways, Settings */

/* Some variables that are based on the source system: */
DECLARE @SourceConnectionID NVARCHAR(100)	= CASE @Source  WHEN 'PowerBIDW'	THEN 'bef20cc1-bad8-481f-a144-56ce175629ea' /* from Connections and Gateways */
															WHEN 'IMDB'			THEN '43e59bcd-34ca-4d12-a331-e57b64357a2f'
															ELSE 'Hello World'
															END;

DECLARE @DatabaseName		NVARCHAR(100)	= CASE @Source	WHEN 'PowerBIDW'	THEN 'PowerBIDW' /* From the Source Server */
                                                            WHEN 'IMDB'         THEN 'IMDB'
															ELSE 'Hello World'
															END;

DECLARE @LakehouseID		NVARCHAR(100)	= CASE @Source	WHEN 'PowerBIDW'	THEN '7757cf9d-9d5d-4446-af76-0c44d18fe317' /* From the browser / URL */
                                                            WHEN 'IMDB'         THEN 'f0b65072-f2b3-49ba-8723-53c377a84ec6'
															ELSE 'Hello World'
															END;

DECLARE @LakehouseName		NVARCHAR(100)	= CASE @Source	WHEN 'PowerBIDW'	THEN 'lh_Bronze_PowerBIDW'
                                                            WHEN 'IMDB'         THEN 'lh_Bronze_IMDB'
															ELSE 'Hello World'
															END;

/* NOTE: Microsoft has not yet exposed Pipeline Schedule ID to the Dynamic Content editor of Pipelines like is available in
Azure Data Factory. Once that happens, then we can start to make use of it here. */
DECLARE @ScheduleIDFULL		NVARCHAR(100)	=	'N/A' ;

DECLARE @ScheduleIDDELTA	NVARCHAR(100)	=	'N/A' ;

/* Should not need to edit anything below this line. */

INSERT INTO [dbo].[MainControlTable] (						
	[SourceObjectSettings],
	[SourceConnectionSettings],		
	[CopySourceSettings],			
	[DestinationObjectSettings],			
	[DestinationConnectionSettings],		
	[CopyDestinationSettings],				
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
	[DestinationObjectSettings]		= '{ "schema": "' + @SinkSchemaName + '", "table":"' + @SinkTableName + '" }',
	[DestinationConnectionSettings]	= '{ "workspaceID": "' + @WorkspaceID + '", "lakehouseConnectionID": "' + @LakehouseConnectionID + '", "lakehouseID": "' + @LakehouseID + '", "sqlConnectionString": "' + @ServerGUID + '.datawarehouse.fabric.microsoft.com", "databaseName": "' + @LakehouseName + '" }',
	[CopyDestinationSettings]		= '{ "tableAction":"Overwrite", "keys": ' + @KeyColumns + ' }',
	[CopyActivitySettings]			= '{ "translator": null }',
	[TopLevelPipelineName]			= 'Top Level Full',
	[ScheduleSettings]				= '{ "scheduleID": "' + @ScheduleIDFULL + '" }',
	[DataLoadingBehaviorSettings]	= '{ "dataLoadingBehavior": "FullLoad", "watermarkColumnName": "' + @WatermarkColumnName + '","watermarkColumnType": "' + @WatermarkColumnType + '",  "watermarkColumnStartValue": "0"} ',
	[TaskId]						= 0,
	[CopyEnabled]					= 1

UNION
/* Delta Load row: */
	SELECT	
	[SourceObjectSettings]			= '{ "Source": "' + @Source + '", "schema": "' + @SourceSchemaName + '", "table": "' + @SourceTableName + '" }',
	[SourceConnectionSettings]		= '{ "sourceConnectionID": "' + @SourceConnectionID + '", "databaseName": "' + @DatabaseName + '" }',
	[CopySourceSettings]			= '{ "partitionOption": "None", "sqlReaderQuery": null, "partitionLowerBound": null, "partitionUpperBound": null, "partitionColumnName": null, "partitionNames": null }',
	[DestinationObjectSettings]		= '{ "schema": "' + @SinkSchemaName + '", "table":"' + @SinkTableName + '" }',
	[DestinationConnectionSettings]	= '{ "workspaceID": "' + @WorkspaceID + '", "lakehouseConnectionID": "' + @LakehouseConnectionID + '", "lakehouseID": "' + @LakehouseID + '", "sqlConnectionString": "' + @ServerGUID + '.datawarehouse.fabric.microsoft.com", "databaseName": "' + @LakehouseName + '" }',
	[CopyDestinationSettings]		= '{ "tableAction": "Upsert", "keys": ' + @KeyColumns + ' }',
	[CopyActivitySettings]			= '{ "translator": null }',
	[TopLevelPipelineName]			= 'Top Level Delta',
	[ScheduleSettings]				= '{ "scheduleID": "' + @ScheduleIDDELTA + '" }',
	[DataLoadingBehaviorSettings]	= '{ "dataLoadingBehavior": "DeltaLoad", "watermarkColumnName": "' + @WatermarkColumnName + '","watermarkColumnType": "' + @WatermarkColumnType + '", "watermarkColumnStartValue": "' + @WatermarkStart + '" }',
	[TaskId]						= 0,
	[CopyEnabled]					= 1
;


GO
