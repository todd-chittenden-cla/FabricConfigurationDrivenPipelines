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
DECLARE @ServerGUID					NVARCHAR(100)	= 'aaaaaaaaaaaaaaaaaaaaaaaaaa-aaaaaaaaaaaaaaaaaaaaaaaaaa'; /* This is the connection string GUID only, minus the .datawarehouse.fabric.microsoft.com */
DECLARE @WorkspaceID				NVARCHAR(100)	= 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'; /* From the browser */
DECLARE @LakehouseConnectionID		NVARCHAR(100)	= 'ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj'; /* From Connections and Gateways, Settings */

/* Some variables that are based on the source system: */
/* Source Connection ID cn be obtained from Connections and Gateways */
DECLARE @SourceConnectionID NVARCHAR(100)	= CASE @Source  WHEN 'PowerBIDW'	THEN 'kkkkkkkk-llll-mmmm-nnnn-oooooooooooo' 
															WHEN 'IMDB'			THEN 'pppppppp-qqqq-rrrr-ssss-tttttttttttt'
															ELSE 'Hello World'
															END;

/* Database Name is from the source server */
DECLARE @DatabaseName		NVARCHAR(100)	= CASE @Source	WHEN 'PowerBIDW'	THEN 'PowerBIDW' 
                                                            WHEN 'IMDB'         THEN 'IMDB'
															ELSE 'Hello World'
															END;

/* Lakehouse IDs can be retrieved from the browser URL when viewing a lakehouse. */
DECLARE @LakehouseID		NVARCHAR(100)	= CASE @Source	WHEN 'PowerBIDW'	THEN 'uuuuuuuu-vvvv-wwww-xxxx-yyyyyyyyyyyy' 
                                                            WHEN 'IMDB'         THEN 'zzzzzzzz-aaaa-bbbb-3333-666666666666'
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
