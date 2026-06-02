/*
This solution strives to be flexible enough to handle most common Watermark column types. 
The stored procedure to generate new Main Control Table rows supports five types:
* DATETIME
* ROWVERSION and TIMESTAMP
* INT and BIGINT

It is important to select one of these four types even if your watermark column is slightly different.
For example, if the data type is DATETIME2, then specify DATETIME. This is because the Lookup Tasks
that query the table after it is loaded has a CASE statement using that type.

For ROWVERSION and TIMESTAMP watermark column types, the actual value can be CAST as a BIGINT
before being saved back to the MainControlTable. Also convenient is the ability to query
the table and specify that BIGINT value in the WHERE clause without needing to convert it
back to the original data typle. For example, these queries to grab delta rows and get the max watermark
value work just fine:

    SELECT * FROM dbo.SomeTable
    WHERE [MyRowVersion] > 123456

    SELECT MAX(CAST([MyRowVersion] AS BIGINT) AS [CurrentMaxWaterMarkColumnValue]
    FROM dbo.SomeTable

If using DATETIME as the Watermark Column Type, the Delta Load query needs to wrap the 
watermark value in quotes:

    SELECT * FROM dbo.SomeTable
    WHERE [MyDateTime] > '01/01/2025'

*/