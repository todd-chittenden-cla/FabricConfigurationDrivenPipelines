CREATE OR ALTER PROCEDURE dbo.CREATE_NEW_Control_Row
(
/* Some Parameters that are table specific: */
    @Source     		    NVARCHAR(20),       /* Options: PowerBIDW | <something to be added later>  */
    @SourceSchemaName	    NVARCHAR(100),      /* Typically 'dbo' but depends on the Source */
    @SourceTableName	    NVARCHAR(100), 
    @KeyColumns			    NVARCHAR(200),	    /* Comma Separated list ["SysRowID"] */	
    @WatermarkColumnName    NVARCHAR(200),	    /* Hopefully something like [LastUpdateDateTime] */
    @WatermarkColumnType    NVARCHAR(100),      /* DATETIME | TIMESTAMP etc. */
    @WatermarkStart         NVARCHAR(100),      /* Example: 1/01/2025 | 0x00000000000 */
    @SinkSchemaName		    NVARCHAR(100),	    /* Typically the same as the SourceSchemaName */
    @SinkTableName		    NVARCHAR(100)	    /* Typically the same as the SourceTableName */
)
AS

/* **************************************
Version History

Version     Date            By                  Notes
=======     ====            ==                  =====
1.0.00      02/13/2026      Todd Chittenden     Initial Version


Notes:
This replaces the script.
Before creating this procedure, the relevant GUIDs and object names need to be populated.

*************************************** */

SET NOCOUNT ON;



/* Some CONSTANT values */
DECLARE @ServerGUID					NVARCHAR(100)	= 'nv664whn3zsefbhnfzmjkcyr6a-5rrjaoi5pncetjuevmvlm6ucnq' /* This is the connection string GUID only, minus the .datawarehouse.fabric.microsoft.com */
DECLARE @WorkspaceID				NVARCHAR(100)	= '399062ec-7b1d-4944-a684-ab2ab67a826c' /* From the browser */
DECLARE @WarehouseConnectionID		NVARCHAR(100)	= '7806a8f9-3815-461d-9a1b-d7a2f1572d29' /* From Connections and Settings */


/* Some variables that are based on the source system: */
DECLARE @SourceConnectionID NVARCHAR(100)	= CASE @Source  WHEN 'PowerBIDW'	THEN '58b0aa11-7295-4767-9912-8cff922e78a' /* can be gotten from the browser */
                                                            WHEN 'Foo'          THEN 'BAR'
															ELSE 'BAR'
															END;

DECLARE @DatabaseName	NVARCHAR(100)		= CASE @Source	WHEN 'PowerBIDW'	THEN 'PowerBIDW' /* From the Source Server */
                                                            WHEN 'Foo'          THEN 'BAR'
															ELSE 'BAR'
															END

DECLARE @WarehouseID		NVARCHAR(100)	= CASE @Source	WHEN 'PowerBIDW'	THEN '58b0aa11-7295-4767-9912-8cff922e78a3'
                                                            WHEN 'Foo'          THEN 'BAR'
															ELSE 'BAR'
															END

DECLARE @WarehouseName		NVARCHAR(100)	= CASE @Source	WHEN 'PowerBIDW'	THEN 'wh_Silver_PowerBIDW'
                                                            WHEN 'Foo'          THEN 'BAR'
															ELSE 'BAR'
															END


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



INSERT INTO [dbo].[MainControlTable] (						
	[SourceObjectSettings],
	[SourceConnectionSettings],		
	[CopySourceSettings],			
	[SinkObjectSettings],			
	[SinkConnectionSettings],		
	[CopySinkSettings],				
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
	[CopyActivitySettings]			= '{ "translator": null }',
	[TopLevelPipelineName]			= 'Top Level Delta',
	[ScheduleSettings]				= '{ "scheduleID": "' + @ScheduleIDDELTA + '" }',
	[DataLoadingBehaviorSettings]	= '{ "dataLoadingBehavior": "DeltaLoad", "watermarkColumnName": "' + @WatermarkColumnName + '","watermarkColumnType": "' + @WatermarkColumnType + '", "watermarkColumnStartValue": "' + @WatermarkStart + '" }',
	[TaskId]						= 0,
	[CopyEnabled]					= 1



GO
