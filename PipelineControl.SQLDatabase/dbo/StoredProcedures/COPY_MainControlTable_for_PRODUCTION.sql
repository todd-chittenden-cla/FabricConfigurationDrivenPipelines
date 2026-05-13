

CREATE   PROCEDURE [dbo].[COPY_MainControlTable_for_PRODUCTION] 

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

    EXEC [dbo].[BACKUP_MainControlTable];

    UPDATE P SET
        --[Id],                             No, we're not updating this, we are JOINING on it                        
        P.[SourceObjectSettings]            = D.[SourceObjectSettings],         
        P.[SourceConnectionSettings]        = D.[SourceConnectionSettings], 
        P.[CopySourceSettings]              = D.[CopySourceSettings],           
        P.[SinkObjectSettings]              = D.[SinkObjectSettings],           
        P.[SinkConnectionSettings]          = D.[SinkConnectionSettings],   
        P.[CopySinkSettings]                = D.[CopySinkSettings],             
        P.[CopyActivitySettings]            = D.[CopyActivitySettings],         
        --P.[TopLevelPipelineName]          = D.[TopLevelPipelineName],         
        --P.[ScheduleSettings]              = D.[ScheduleSettings]],                  
        P.[DataLoadingBehaviorSettings]     = D.[DataLoadingBehaviorSettings],  
        P.[TaskId]                          = D.[TaskId],                     
        --P.[CopyEnabled]                   = D.[CopyEnabled],                  
        P.[LastRunDateTime]                 = D.[LastRunDateTime]
    FROM [dbo].[MainControlTable]               AS P -- Production
    INNER JOIN [dbo].[MainControlTable_DEBUG]   AS D -- DEBUG
        ON P.Id = D.Id
    WHERE
        P.Id = @Id
    AND D.Id = @Id
    ;

END

GO

