

/*
This script will populate the DEBUG Main Control Table in the Fabric SQL database
with  records from the Production MCT. 

one for a FULL load and one for a DELTA load of the listed table.



*/


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
;

TRUNCATE TABLE dbo.MainControlTable_DEBUG;

EXEC [dbo].[COPY_MainControlTable_for_DEBUG] 1
EXEC [dbo].[COPY_MainControlTable_for_DEBUG] 2

SELECT * FROM dbo.MainControlTable_DEBUG;





/* update the Delta Load */
UPDATE dbo.MainControlTable_DEBUG SET CopyEnabled = 0
WHERE JSON_VALUE([DataLoadingBehaviorSettings], '$.dataLoadingBehavior') = 'DeltaLoad';

/* update the Full load */
UPDATE dbo.MainControlTable_DEBUG SET CopyEnabled = 1
WHERE JSON_VALUE([DataLoadingBehaviorSettings], '$.dataLoadingBehavior') = 'FullLoad';



/* Now go in and run the Top LEvel Debug pipeline */


/* UPDATE BOTH rows */
DECLARE @sqlReaderQuery NVARCHAR(MAX) = 'SELECT [Company],[OpenLine],[VoidLine],[PONUM],[POLine],LEFT([LineDesc], 4000) AS [LineDesc],[IUM],[UnitCost],[DocUnitCost],[OrderQty],[XOrderQty],[Taxable],[PUM],[CostPerCode],[PartNum],[VenPartNum],LEFT([CommentText], 4000) AS [CommentText],[ClassID],[RevisionNum],[RcvInspectionReq],[VendorNum],[AdvancePayBal],[DocAdvancePayBal],[Confirmed],[DateChgReq],[QtyChgReq],[PartNumChgReq],[RevisionNumChgReq],[ConfirmDate],[ConfirmVia],[PrcChgReq],[PurchCode],[OrderNum],[OrderLine],[Linked],[ExtCompany],[GlbCompany],[ContractActive],[ContractQty],[ContractUnitCost],[ContractDocUnitCost],[Rpt1AdvancePayBal],[Rpt2AdvancePayBal],[Rpt3AdvancePayBal],[Rpt1UnitCost],[Rpt2UnitCost],[Rpt3UnitCost],[ContractQtyUOM],[Rpt1ContractUnitCost],[Rpt2ContractUnitCost],[Rpt3ContractUnitCost],[BaseQty],[BaseUOM],[BTOOrderNum],[BTOOrderLine],[VendorPartOpts],[MfgPartOpts],[SubPartOpts],[MfgNum],[MfgPartNum],[SubPartNum],[SubPartType],[ConfigUnitCost],[ConfigBaseUnitCost],[ConvOverRide],[BasePartNum],[BaseRevisionNum],[Direction],[Per],[MaintainPricingUnits],[OverrideConversion],[RowsManualFactor],[KeepRowsManualFactorTmp],[ShipToSupplierDate],[Factor],[PricingQty],[PricingUnitPrice],[UOM],[SysRevID],[SysRowID],[GroupSeq],[DocPricingUnitPrice],[OverridePriceList],[QtyOption],[OrigComment],[SmartString],[SmartStringProcessed],[DueDate],[ContractID],[LinkToContract],[SelCurrPricingUnitPrice],[ChangedBy],[ChangeDate],[PCLinkRemoved],[TaxCatID],[NoTaxRecalc],[InUnitCost],[DocInUnitCost],[Rpt1InUnitCost],[Rpt2InUnitCost],[Rpt3InUnitCost],[InAdvancePayBal],[DocInAdvancePayBal],[Rpt1InAdvancePayBal],[Rpt2InAdvancePayBal],[Rpt3InAdvancePayBal],[InContractUnitCost],[DocInContractUnitCost],[Rpt1InContractUnitCost],[Rpt2InContractUnitCost],[Rpt3InContractUnitCost],[DocExtCost],[ExtCost],[Rpt1ExtCost],[Rpt2ExtCost],[Rpt3ExtCost],[DocMiscCost],[MiscCost],[Rpt1MiscCost],[Rpt2MiscCost],[Rpt3MiscCost],[TotalTax],[DocTotalTax],[Rpt1TotalTax],[Rpt2TotalTax],[Rpt3TotalTax],[TotalSATax],[DocTotalSATax],[Rpt1TotalSATax],[Rpt2TotalSATax],[Rpt3TotalSATax],[TotalDedTax],[DocTotalDedTax],[Rpt1TotalDedTax],[Rpt2TotalDedTax],[Rpt3TotalDedTax],[CommodityCode],[CNBonded],[EDIAckCode],[EDIAckComment]FROM [Erp].[PODetail]'

UPDATE dbo.MainControlTable_DEBUG SET 
	--CopySourceSettings = JSON_MODIFY(CopySourceSettings, '$.sqlReaderQuery', @sqlReaderQuery )
	SinkObjectSettings = JSON_MODIFY(SinkObjectSettings, '$.schema', 'Ice')


/* Update the Merge stuff for the Delta row */
DECLARE @MergeProcedureSettings NVARCHAR(MAX) = '{  "mergeConnectionID": "88f11eff-1e4a-4b91-aae2-e032a0ddb6a7",  "workspaceID": "7c85f4dd-77cc-4a42-8348-b8f15d78bde6",  "warehouseID": "ebe19a2f-7bd7-475e-a9a7-a1d23573c4ee",  "sqlConnectionString": "hlou5htjmmbubf6lhmt66cyi44-3x2ik7gmo5beva2ixdyv26f54y.datawarehouse.fabric.microsoft.com",  "databaseName": "wh_Silver_Colt_CA",  "storedProcedure": "Ice.MERGE_UDCodes"}'
UPDATE dbo.MainControlTable_DEBUG SET MergeProcedureSettings = @MergeProcedureSettings
WHERE Id = 233






SELECT * FROM dbo.MainControlTable_DEBUG;

/* Push it back to Main Control Table */
EXEC [dbo].[COPY_MainControlTable_for_PRODUCTION] 387
EXEC [dbo].[COPY_MainControlTable_for_PRODUCTION] 388





/* This Works */

SELECT coalesce(convert(VARCHAR(50), max([SysRevID]), 1 ), '0x0') as CurrentMaxWaterMarkColumnValue FROM [@{json(item().SinkObjectSettings).schema}].[@{json(item().SinkObjectSettings).table}]

SELECT coalesce(convert(VARCHAR(50), max([@{json(item().DataLoadingBehaviorSettings).watermarkColumnName}]), 1 ), '0x0') as CurrentMaxWaterMarkColumnValue FROM [@{json(item().SinkObjectSettings).schema}].[@{json(item().SinkObjectSettings).table}]

SELECT coalesce(convert(VARCHAR(50), max([@{json(activity('Get Delta Load Id').output.firstRow.DataLoadingBehaviorSettings).watermarkColumnName}]), 1 ), '0x0') as CurrentMaxWaterMarkColumnValue FROM [@{json(item().SinkObjectSettings).schema}].[@{json(item().SinkObjectSettings).table}]



