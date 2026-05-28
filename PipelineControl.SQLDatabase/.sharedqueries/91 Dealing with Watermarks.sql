/*
This solution strives to be flexible enough to handle most common Watermark column types. 
The stored procedure to generate new Main Control Table rows supports four types:
* DATETIME
* ROWVERSION
* TIMESTAMP
* INT

It is important to select one of these four types even if your watermark column is slightly different.
For example, if the data type is DATETIME2, then select DATETIME. This is because the Lookup Tasks
that query the table after it is loaded has a CASE statement using that type.

For Delta Loads, the dynamic content is as follows:

    @{if(
        equals(json(item().DataLoadingBehaviorSettings).watermarkColumnType, 'ROWVERSION'),
        concat(
            'SELECT MAX(CAST([',
            json(item().DataLoadingBehaviorSettings).watermarkColumnName,
            '] AS BIGINT)) AS CurrentMaxWaterMarkColumnValue FROM [',
            json(item().DestinationObjectSettings).schema,
            '].[', 
            json(item().DestinationObjectSettings).table,
            ']'
        ),

        if(
        equals(json(item().DataLoadingBehaviorSettings).watermarkColumnType, 'TIMESTAMP'),
        concat(
            'SELECT MAX(CAST([',
            json(item().DataLoadingBehaviorSettings).watermarkColumnName,
            '] AS BIGINT)) AS CurrentMaxWaterMarkColumnValue FROM [',
            json(item().DestinationObjectSettings).schema,
            '].[', 
            json(item().DestinationObjectSettings).table,
            ']'
        ),

        if(
            equals(json(item().DataLoadingBehaviorSettings).watermarkColumnType, 'INT'),
            concat(
                'SELECT MAX([',
                json(item().DataLoadingBehaviorSettings).watermarkColumnName,
                ']) AS CurrentMaxWaterMarkColumnValue FROM [',
                json(item().DestinationObjectSettings).schema,
                '].[', 
                json(item().DestinationObjectSettings).table,
                ']'
            ),

            concat(
                'SELECT MAX(CAST([',
                json(item().DataLoadingBehaviorSettings).watermarkColumnName,
                '] AS DATETIME2)) AS CurrentMaxWaterMarkColumnValue FROM [',
                json(item().DestinationObjectSettings).schema,
                '].[', 
                json(item().DestinationObjectSettings).table,
                ']'
            )
        ))
    )}


This can be abbreviated down to:

SELECT 
    MAX(
        CASE {watermarkColumnType}
            WHEN 'ROWVERSION'  THEN CAST([{watermarkColumnName}] AS VARBINARY(8))
            WHEN 'INT'         THEN CAST([{watermarkColumnName}] AS BIGINT)
            WHEN 'DATETIME'    THEN CAST([{watermarkColumnName}] AS DATETIME2)
        END
    ) AS CurrentMaxWaterMarkColumnValue 
FROM [{schema}].[{table}]

The Full Load is similar, but gets the watermark column Type and Name
from the task "Get Delta Load Id".












*/