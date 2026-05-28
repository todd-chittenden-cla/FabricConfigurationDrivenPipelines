

CREATE   VIEW dbo.MainControlTable_JSON_FLATTENED_DEBUG
AS

SELECT
    Id,
    JSON_VALUE([SourceObjectSettings], '$.Source')  AS [Source],
    JSON_VALUE([SourceObjectSettings], '$.schema')  AS [SourceSchema],
    JSON_VALUE([SourceObjectSettings], '$.table')   AS [SourceTable],

        [SourceConnectionSettings]
      ,[CopySourceSettings]
      ,[DestinationObjectSettings]
      ,[DestinationConnectionSettings]
      ,[CopyDestinationSettings]
      ,[CopyActivitySettings]
      ,[TopLevelPipelineName]
      ,[ScheduleSettings]
      ,[DataLoadingBehaviorSettings]
      ,[TaskId]
      ,[CopyEnabled]
      ,[LastRunDateTime]



FROM [dbo].[MainControlTable_DEBUG]

GO

