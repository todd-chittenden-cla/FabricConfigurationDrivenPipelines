EXEC dbo.CREATE_NEW_Control_Row

    @Source     		    = 'PowerBIDW',
    @SourceSchemaName	    = 'dbo',
    @SourceTableName	    = 'BusinessUnit',
    @KeyColumns			    = 'BusinessUnitCode',
    @WatermarkColumnName    = 'LastUpdateDateTime',
    @WatermarkColumnType    = 'DATETIME',
    @WatermarkStart         = '01/01/2025',
    @SinkSchemaName		    = 'dbo',
    @SinkTableName		    = 'BusinessUnit'

/*

TRUNCATE TABLE dbo.MainControlTable    

SELECT * FROM dbo.MainControlTable;

*/