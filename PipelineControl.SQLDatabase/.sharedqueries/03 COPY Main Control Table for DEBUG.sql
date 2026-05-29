


/****** Object:  StoredProcedure [adf_control].[COPY_MainControlTable_for_DEBUG]    Script Date: 11/10/2025 10:45:07 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[COPY_MainControlTable_for_DEBUG] 
    @Id [INT] 
AS

/* **************************************
Version History

Version     Date            By                  Notes
=======     ====            ==                  =====
1.0.00      04/??/2022      Todd Chittenden     Initial Version
2.0.00		11/10/2025		Todd Chittenden		Migrated to Fabric SQL Database


Notes:


*************************************** */


BEGIN
/* If the record exists already, clear it out */
    DELETE FROM [dbo].[MainControlTable_DEBUG]
    WHERE Id = @Id;



/* Copy *most* of the fields over: */
    INSERT INTO [dbo].[MainControlTable_DEBUG] (	
        [Id],
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
	    [CopyEnabled],
        [LastRunDateTime]
	    )
    SELECT
        [Id],                          
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
        1                                   AS [CopyEnabled],                  
        NULL                                AS [LastRunDateTime]
    FROM [dbo].[MainControlTable]
    WHERE
        Id = @Id;



END
GO

