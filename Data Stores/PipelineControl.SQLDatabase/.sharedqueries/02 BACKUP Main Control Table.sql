

/****** Object:  StoredProcedure [adf_control].[BACKUP_MainControlTable]    Script Date: 11/10/2025 10:36:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROC [dbo].[BACKUP_MainControlTable] AS

/* **************************************
Version History

Version     Date            By                  Notes
=======     ====            ==                  =====
1.0.00      04/??/2022      Todd Chittenden     Initial Version
2.0.00		11/10/2025		Todd Chittenden		Migrated to Fabric SQL Database


Notes:


*************************************** */


DECLARE @SaveDate DATE = CAST(GETDATE() AS DATE);

--SELECT @SaveDate;


DELETE FROM [dbo].[MainControlTable_BACKUP]
WHERE 
	[SaveDate] = @SaveDate;



INSERT INTO [dbo].[MainControlTable_BACKUP]
SELECT 
	@SaveDate,
	* 
FROM [dbo].[MainControlTable];
GO

/* SELECT * FROM [dbo].[MainControlTable_BACKUP] */