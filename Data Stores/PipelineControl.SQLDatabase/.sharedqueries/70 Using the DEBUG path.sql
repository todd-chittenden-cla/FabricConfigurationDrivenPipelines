/*
This solution has the capability to do one-off debugging:


 A) TRUNCATE the table MainControlTable_DEBUG
 B) Identify pairs of rows (Full and Delta) for a table to debug.
 C) Run the procedure COPY_MainControlTable_for_DEBUG once for each row, using the Id as the input parameter.
 D) Run either the Top Level Full or Top Level Delta pipeline and specify 1 for the Debug parameter.
 E) Review the results. Make changes as needed. Repeat until it behaves as expected without errors.
 F) Run the procedure COPY_MainControlTable_for_PRODUCTION once for each row, speifying the Id as the input parameter.


When a Top Level Pipeline is run in DEBUG mode:
    *) It pulls data from the MainControlTable_DEBUG via view



*/

/* === A) Clear out the DEBUG Main Control Table === */

TRUNCATE TABLE dbo.MainControlTable_DEBUG;

/* === B) Identify the rows you want. For thisexample, I want the two rows for dbo.BusinessUnit from the PowerBIDW database. 
NOTE: If you are going to test a FULL Load row, make sure to also copy the DELTA row over to the DEBUG table as the Full Load
pipeline path interfaces with that row to record the latest Watermark value. === */

SELECT 
	Id,
	JSON_VALUE([SourceObjectSettings], '$.Source') AS [Source],
	JSON_VALUE([SourceObjectSettings], '$.table') AS [Table Name],
	JSON_VALUE([DataLoadingBehaviorSettings], '$.dataLoadingBehavior') AS [Load Type],
	LastRunDateTime,
	CopyEnabled
FROM dbo.MainControlTable
WHERE 
	JSON_VALUE([SourceObjectSettings], '$.table') = 'BusinessUnit'
AND JSON_VALUE([SourceObjectSettings], '$.Source') = 'PowerBIDW'
;

/* === C) Copy the rows over the the DEBUG table === */


EXEC [dbo].[COPY_MainControlTable_for_DEBUG] 1;
EXEC [dbo].[COPY_MainControlTable_for_DEBUG] 2;

/* Verify the contents of the table: */

SELECT * FROM dbo.MainControlTable_DEBUG;


/* === D) Run the Top Level Pipeline FULL or DELTA and specify 1 as the DEBUG parameter (default is 0) === */

/* === E) Make edits to the MainControlTable_DEBUG and re-run the top level pipeline(s) as needed === */

/* I leave it up to you, dear reader, to work out what you need to change.

UPDATE dbo.COPY_MainControlTable_for_DEBUG SET
    SourceObjectSettings = '{ "Source": "PowerBIDW", "schema": "dbo", "table": "BusinessUnit" }'

*/


/* === F) Push the rows back to Main Control Table === */
EXEC [dbo].[COPY_MainControlTable_for_PRODUCTION] 1;
EXEC [dbo].[COPY_MainControlTable_for_PRODUCTION] 2;