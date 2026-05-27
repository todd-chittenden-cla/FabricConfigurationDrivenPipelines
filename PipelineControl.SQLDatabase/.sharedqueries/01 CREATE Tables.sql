


/****** Object:  Table [dbo].[MainControlTable]    Script Date: 11/6/2025 3:58:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE [dbo].[MainControlTable];
GO


CREATE TABLE [dbo].[MainControlTable](
	[Id]							INT					IDENTITY(1,1) NOT NULL,
	[SourceObjectSettings]			NVARCHAR(MAX) NULL,
	[SourceConnectionSettings]		NVARCHAR(MAX) NULL,
	[CopySourceSettings]			NVARCHAR(MAX) NULL,
	[DestinationObjectSettings]		NVARCHAR(MAX) NULL,
	[DestinationConnectionSettings]	NVARCHAR(MAX) NULL,
	[CopyDestinationSettings]		NVARCHAR(MAX) NULL,
	[CopyActivitySettings]			NVARCHAR(MAX) NULL,
	[TopLevelPipelineName]			NVARCHAR(MAX) NULL,
	[ScheduleSettings]				NVARCHAR(MAX) NULL,
	[DataLoadingBehaviorSettings]	NVARCHAR(MAX) NULL,
	[TaskId]						INT NULL,
	[CopyEnabled]					BIT NOT NULL DEFAULT(0),
	[LastRunDateTime]				[datetime] NULL,
 CONSTRAINT [PK_MainControlTable_ID] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
) 
GO


DROP TABLE [dbo].[MainControlTable_DEBUG];
GO

CREATE TABLE [dbo].[MainControlTable_DEBUG](
	[Id]							INT		  NOT NULL,
	[SourceObjectSettings]			NVARCHAR(MAX) NULL,
	[SourceConnectionSettings]		NVARCHAR(MAX) NULL,
	[CopySourceSettings]			NVARCHAR(MAX) NULL,
	[DestinationObjectSettings]		NVARCHAR(MAX) NULL,
	[DestinationConnectionSettings]	NVARCHAR(MAX) NULL,
	[CopyDestinationSettings]		NVARCHAR(MAX) NULL,
	[CopyActivitySettings]			NVARCHAR(MAX) NULL,
	[TopLevelPipelineName]			NVARCHAR(MAX) NULL,
	[ScheduleSettings]				NVARCHAR(MAX) NULL,
	[DataLoadingBehaviorSettings]	NVARCHAR(MAX) NULL,
	[TaskId]						INT NULL,
	[CopyEnabled]					BIT NOT NULL DEFAULT(0),
	[LastRunDateTime]				[datetime] NULL,
 CONSTRAINT [PK_MainControlTable_ID_DEBUG] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
) 
GO


DROP TABLE [dbo].[MainControlTable_BACKUP];
GO

CREATE TABLE [dbo].[MainControlTable_BACKUP](
	[SaveDate]						DATE	  NOT NULL,
	[Id]							INT		  NOT NULL,
	[SourceObjectSettings]			NVARCHAR(MAX) NULL,
	[SourceConnectionSettings]		NVARCHAR(MAX) NULL,
	[CopySourceSettings]			NVARCHAR(MAX) NULL,
	[DestinationObjectSettings]		NVARCHAR(MAX) NULL,
	[DestinationConnectionSettings]	NVARCHAR(MAX) NULL,
	[CopyDestinationSettings]		NVARCHAR(MAX) NULL,
    [CopyActivitySettings]			NVARCHAR(MAX) NULL,
	[TopLevelPipelineName]			NVARCHAR(MAX) NULL,
	[ScheduleSettings]				NVARCHAR(MAX) NULL,
	[DataLoadingBehaviorSettings]	NVARCHAR(MAX) NULL,
	[TaskId]						INT NULL,
	[CopyEnabled]					BIT NOT NULL DEFAULT(0),
	[LastRunDateTime]				[datetime] NULL,
 CONSTRAINT [PK_MainControlTable_ID_BACKUP] PRIMARY KEY CLUSTERED 
(
	[SaveDate],
	[Id]
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
) 
GO

TRUNCATE TABLE dbo.MainControlTable;

SELECT * FROM dbo.MainControlTable;
UPDATE dbo.MainControlTable SET CopyEnabled = 0 WHERE Id = 2;
GO

