

/*

Usefull JSON Properties:

SourceConnectionSettings:
	@json(item().SourceConnectionSettings).sourceConnectionID
	@json(item().SourceConnectionSettings).databaseName

SourceObjectSettings:
	@json(item().SourceObjectSettings).schema
	@json(item().SourceObjectSettings).table


CopySourceSettings:
	@json(item().CopySourceSettings).sqlReaderQuery

SinkObjectSettings:
	@json(item().SinkObjectSettings).schema  @{json(item().SinkObjectSettings).schema}
	@json(item().SinkObjectSettings).table

SinkConnectionSettings:
	@json(item().SinkConnectionSettings).warehouseConnectionID
	@json(item().SinkConnectionSettings).lakehouseConnectionID
	@json(item().SinkConnectionSettings).workspaceID
	@json(item().SinkConnectionSettings).warehouseID
	@json(item().SinkConnectionSettings).lakehouseID
	@json(item().SinkConnectionSettings).sqlConnectionString

CopySinkSettings:

	IF OBJECT_ID('@{json(item().SinkObjectSettings).schema}.@{json(item().SinkObjectSettings).table}', 'U') IS NOT NULL 
@{json(item().CopySinkSettings).preCopyOption} TABLE @{json(item().SinkObjectSettings).schema}.@{json(item().SinkObjectSettings).table};


	@{json(item().CopySinkSettings).preCopyOption}

	@json(item().CopySinkSettings).preCopyScript
	@json(item().CopySinkSettings).tableOption
	@json(item().CopySinkSettings).waitTime

MergeProcedureSettings:
	@json(item().MergeProcedureSettings).mergeConnectionID
	@json(item().MergeProcedureSettings).workspaceID
	@json(item().MergeProcedureSettings).warehouseID
	@json(item().MergeProcedureSettings).sqlConnectionString
	@json(item().MergeProcedureSettings).storedProcedure

Delta Watermark Lookup:


CopyActivitySettings:
	@json(item().CopyActivitySettings).translator


ScheduleSettings:
	@json(item().ScheduleSettings).scheduleID

DataLoadingBehaviorSettings
	@json(item().DataLoadingBehaviorSettings).dataLoadingBehavior
	@{json(item().DataLoadingBehaviorSettings).watermarkColumnName}
	@json(item().DataLoadingBehaviorSettings).watermarkColumnType
	@json(item().DataLoadingBehaviorSettings).watermarkColumnStartValue


Full Load Query:

@if(equals(json(item().CopySourceSettings).sqlReaderQuery,null), 
concat('SELECT * FROM ', json(item().SourceObjectSettings).schema, '.', json(item().SourceObjectSettings).table), json(item().CopySourceSettings).sqlReaderQuery)

Delta Load Query:
@if(equals(json(item().CopySourceSettings).sqlReaderQuery,null), 
concat('SELECT * FROM ', json(item().SourceObjectSettings).schema, '.', json(item().SourceObjectSettings).table, ' WHERE [', json(item().DataLoadingBehaviorSettings).watermarkColumnName, '] > ', json(item().DataLoadingBehaviorSettings).watermarkColumnStartValue ), 
concat(json(item().CopySourceSettings).sqlReaderQuery, ' WHERE [', json(item().DataLoadingBehaviorSettings).watermarkColumnName, '] > ', json(item().DataLoadingBehaviorSettings).watermarkColumnStartValue )
)


SELECT * FROM dbo.MainControlTable;


*/

