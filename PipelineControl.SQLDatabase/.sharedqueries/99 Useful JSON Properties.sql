
/*

Usefull JSON Properties for Dynamic Content:

SourceConnectionSettings:
	@json(item().SourceConnectionSettings).sourceConnectionID
	@json(item().SourceConnectionSettings).databaseName

SourceObjectSettings:
	@json(item().SourceObjectSettings).schema
	@json(item().SourceObjectSettings).table


CopySourceSettings:
	@json(item().CopySourceSettings).sqlReaderQuery

DestinationObjectSettings:
	@json(item().DestinationObjectSettings).schema or @{json(item().DestinationObjectSettings).schema}
	@json(item().DestinationObjectSettings).table

DestinationConnectionSettings:
	@json(item().DestinationConnectionSettings).warehouseConnectionID
	@json(item().DestinationConnectionSettings).lakehouseConnectionID
	@json(item().DestinationConnectionSettings).workspaceID
	@json(item().DestinationConnectionSettings).warehouseID
	@json(item().DestinationConnectionSettings).lakehouseID
	@json(item().DestinationConnectionSettings).sqlConnectionString

CopyDestinationSettings:

	IF OBJECT_ID('@{json(item().DestinationObjectSettings).schema}.@{json(item().DestinationbjectSettings).table}', 'U') IS NOT NULL 
@{json(item().CopyDestinationSettings).preCopyOption} TABLE @{json(item().DestinationObjectSettings).schema}.@{json(item().DestinationObjectSettings).table};



	@{json(item().CopyDestinationSettings).preCopyOption}

	
	@json(item().CopyDestinationSettings).tableAction

	@json(item().CopyDestinationSettings).waitTime

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
	@{json(item().DataLoadingBehaviorSettings).watermarkColumnType}
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

