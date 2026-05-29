/*

TRUNCATE TABLE dbo.MainControlTable    

SELECT * FROM dbo.MainControlTable;

*/

EXEC dbo.CREATE_NEW_Control_Row
    @Source     		    = 'PowerBIDW',
    @SourceSchemaName	    = 'dbo',
    @SourceTableName	    = 'BusinessUnit',
    @KeyColumns			    = '[ "BusinessUnitCode" ]', /* Example for Multi-Key table: ["Column1, Column2"]*/
    @WatermarkColumnName    = 'LastUpdateDateTime',
    @WatermarkColumnType    = 'DATETIME',
    @WatermarkStart         = '01/01/2025',
    @SinkSchemaName		    = 'dbo',
    @SinkTableName		    = 'BusinessUnit'
    ;


EXEC dbo.CREATE_NEW_Control_Row
    @Source     		    = 'IMDB',
    @SourceSchemaName	    = 'dbo',
    @SourceTableName	    = 'Genre',
    @KeyColumns			    = '[ "GenreKey" ]',
    @WatermarkColumnName    = 'ROWVERSION',
    @WatermarkColumnType    = 'TIMESTAMP',
    @WatermarkStart         = '0',
    @SinkSchemaName		    = 'dbo',
    @SinkTableName		    = 'Genre'
    ;