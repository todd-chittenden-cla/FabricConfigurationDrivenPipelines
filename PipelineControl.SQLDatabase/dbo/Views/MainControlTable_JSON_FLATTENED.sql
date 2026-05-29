CREATE   VIEW dbo.MainControlTable_JSON_FLATTENED
AS

/* **************************************
Version History

Version     Date            By                  Notes
=======     ====            ==                  =====
1.0.00      02/13/2026      Todd Chittenden     Initial Version


Notes:
This VIEW uses JSON_VALUE (and in one case JSON_QUERY) to flatten the JSON data in most of the 
columns of the Main Control Table. It also builds the Delta Load query and the query used to 
get the MAX Watermark value (WatermarkQuery). This simplifies the dynamic content in the pipeline
when referring to various elements.

*************************************** */

SELECT
    Id,
    JSON_VALUE([SourceObjectSettings], '$.Source')                              AS [Source],            /* @item().Source */
    JSON_VALUE([SourceObjectSettings], '$.schema')                              AS [SourceSchema],      /* @item().SourceSchema */
    JSON_VALUE([SourceObjectSettings], '$.table')                               AS [SourceTable],       /* @item().SourceTable */

    JSON_VALUE([SourceConnectionSettings], '$.sourceConnectionID')              AS [SourceConnectionID],    /* @item().SourceConnectionID */
    JSON_VALUE([SourceConnectionSettings], '$.databaseName')                    AS [SourceDatabaseName],    /* @item().SourceDatabaseName */

    /* SourceQuery used only for the DeltaLoad */
    'SELECT * FROM [' + JSON_VALUE([SourceObjectSettings], '$.schema') + '].[' + JSON_VALUE([SourceObjectSettings], '$.table') + '] 
    WHERE [' + JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnName') + '] >
    ' + CASE JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnType')
            WHEN 'INT'          THEN JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnStartValue')
            WHEN 'BIGINT'       THEN JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnStartValue')
            WHEN 'ROWVERSION'   THEN JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnStartValue')
            WHEN 'TIMESTAMP'    THEN JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnStartValue')
            WHEN 'DATETIME'     THEN '''' + JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnStartValue') + ''''
    ELSE JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnName')
    END                                                                         AS [SourceQuery], /* @item().SourceQuery */

    JSON_VALUE([DestinationObjectSettings], '$.schema')                         AS [DestinationSchema],     /* @item().DestinationSchema */
    JSON_VALUE([DestinationObjectSettings], '$.table')                          AS [DestinationTable],      /* @item().DestinationTable */
    /* DestinationConnectionSettings */ 
    JSON_VALUE([DestinationConnectionSettings], '$.workspaceID')                AS [WorkspaceID],           /* @item().WorkspaceID */
    JSON_VALUE([DestinationConnectionSettings], '$.lakehouseConnectionID')      AS [LakehouseConnectionID], /* @item().LakehouseConnectionID */
    JSON_VALUE([DestinationConnectionSettings], '$.lakehouseID')                AS [LakehouseID],           /* @item().LakehouseID */
    JSON_VALUE([DestinationConnectionSettings], '$.sqlConnectionString')        AS [SQLConnectionString],   /* @item().SQLConnectionString] */
    JSON_VALUE([DestinationConnectionSettings], '$.databaseName')               AS [DestinationDatabaseName],/* @item().DestinationDatabaseName */

    JSON_VALUE([CopyDestinationSettings], '$.tableAction')  AS [TableAction],                               /* @item().TableAction  */
    JSON_VALUE([CopyActivitySettings], '$.translator')      AS [MappingTranslator],                         /* @item().MappingTranslator  */
    [TopLevelPipelineName],
    [ScheduleSettings],
    JSON_VALUE([DataLoadingBehaviorSettings], '$.dataLoadingBehavior')          AS [DataLoadingBehavior],    /* @item().DataLoadingBehavior  */
    JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnName')          AS [WatermarkColumnName],
    JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnType')          AS [WatermarkColumnType],
    JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnStartValue')    AS [watermarkColumnStartValue],

    'SELECT MAX(CAST([' + JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnName') + '] AS ' +
    CASE JSON_VALUE([DataLoadingBehaviorSettings], '$.watermarkColumnType')
        WHEN 'INT'          THEN 'BIGINT'
        WHEN 'BIGINT'       THEN 'BIGINT'
        WHEN 'ROWVERSION'   THEN 'BIGINT'
        WHEN 'TIMESTAMP'    THEN 'BIGINT'
        WHEN 'DATETIME'     THEN 'DATETIME2'
        END + ')) AS [CurrentMaxWaterMarkColumnValue] FROM [' + JSON_VALUE([DestinationObjectSettings], '$.schema') 
        + '].[' + JSON_VALUE([DestinationObjectSettings], '$.table') + ']'      AS [WatermarkQuery], /* @item().WatermarkQuery  */
    JSON_QUERY([CopyDestinationSettings], '$.keys') AS [UpsertKeys],                                    /* @item().UpsertKeys  */
    [TaskId],
    [CopyEnabled],
    [LastRunDateTime]
FROM [dbo].[MainControlTable]

GO

