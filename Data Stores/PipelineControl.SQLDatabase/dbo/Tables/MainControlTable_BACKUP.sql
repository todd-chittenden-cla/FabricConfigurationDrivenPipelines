CREATE TABLE [dbo].[MainControlTable_BACKUP] (
    [SaveDate]                      DATE           NOT NULL,
    [Id]                            INT            NOT NULL,
    [SourceObjectSettings]          NVARCHAR (MAX) NULL,
    [SourceConnectionSettings]      NVARCHAR (MAX) NULL,
    [CopySourceSettings]            NVARCHAR (MAX) NULL,
    [DestinationObjectSettings]     NVARCHAR (MAX) NULL,
    [DestinationConnectionSettings] NVARCHAR (MAX) NULL,
    [CopyDestinationSettings]       NVARCHAR (MAX) NULL,
    [CopyActivitySettings]          NVARCHAR (MAX) NULL,
    [TopLevelPipelineName]          NVARCHAR (MAX) NULL,
    [ScheduleSettings]              NVARCHAR (MAX) NULL,
    [DataLoadingBehaviorSettings]   NVARCHAR (MAX) NULL,
    [TaskId]                        INT            NULL,
    [CopyEnabled]                   BIT            DEFAULT ((0)) NOT NULL,
    [LastRunDateTime]               DATETIME       NULL,
    CONSTRAINT [PK_MainControlTable_ID_BACKUP] PRIMARY KEY CLUSTERED ([SaveDate] ASC, [Id] ASC)
);


GO

