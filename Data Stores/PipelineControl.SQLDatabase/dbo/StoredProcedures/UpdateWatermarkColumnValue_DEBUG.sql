


CREATE   PROC [dbo].[UpdateWatermarkColumnValue_DEBUG] 
	@Type						NVARCHAR(10),
	@watermarkColumnStartValue [NVARCHAR](100),
	@Id [INT] 

AS

/* **************************************
Version History

Version     Date            By                  Notes
=======     ====            ==                  =====
1.0.00      04/??/2022      Todd Chittenden     Initial Version
2.0.01		07/20/2022		Todd Chittenden		Allowing for FullLoad Main Control Table rows by passing in
												a value of 'FullLoad' in the Watermark parameter.
												Changed Parameter to NVARCHAR(100) vice MAX.
3.0.00		11/10/2025		Todd Chittenden		Migrated to Fabric SQL Control
3.1.01		12/05/2025		Todd Chittenden		Added Parameter @Type and logic

Notes:
Probably going to need adjustments as 

*************************************** */


IF @Type = 'FullLoad'
BEGIN
	UPDATE [dbo].[MainControlTable_DEBUG]
		SET LastRunDateTime = GETDATE()
	WHERE Id = @Id
END

IF @Type = 'DeltaLoad'
BEGIN
	UPDATE [dbo].[MainControlTable_DEBUG]
	SET 
		[DataLoadingBehaviorSettings] = JSON_MODIFY([DataLoadingBehaviorSettings],'$.watermarkColumnStartValue', @watermarkColumnStartValue) ,
		LastRunDateTime = GETDATE()
	WHERE Id = @Id
END

IF @Type = 'Watermark'
BEGIN
	UPDATE [dbo].[MainControlTable_DEBUG]
	SET 
		[DataLoadingBehaviorSettings] = JSON_MODIFY([DataLoadingBehaviorSettings],'$.watermarkColumnStartValue', @watermarkColumnStartValue)
	WHERE Id = @Id
END

GO

