USE [imagema1_DocDB]
GO
/****** Object:  Table [imagema1_docuser].[tblAllocation]    Script Date: 22/09/2026 03:59:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [imagema1_docuser].[tblAllocation](
	[AllocationId] [int] IDENTITY(1,1) NOT NULL,
	[ProjectId] [int] NULL,
	[ResourceId] [int] NULL,
	[date] [date] NULL,
	[HourseWorked] [numeric](18, 2) NULL,
	[TaskComplexity] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[AllocationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [imagema1_docuser].[tblDesignation]    Script Date: 22/09/2026 03:59:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [imagema1_docuser].[tblDesignation](
	[DesignationId] [int] IDENTITY(1,1) NOT NULL,
	[Designation] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[DesignationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [imagema1_docuser].[tblProject]    Script Date: 22/09/2026 03:59:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [imagema1_docuser].[tblProject](
	[ProjectId] [int] IDENTITY(1,1) NOT NULL,
	[ProjectName] [nvarchar](100) NULL,
	[StartSate] [date] NULL,
	[EndDate] [date] NULL,
	[EstimatedBudget] [numeric](18, 2) NULL,
	[ApprovedBudget] [numeric](18, 2) NULL,
	[RiskFactor] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [imagema1_docuser].[tblResource]    Script Date: 22/09/2026 03:59:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [imagema1_docuser].[tblResource](
	[ResourceId] [int] IDENTITY(1,1) NOT NULL,
	[FullName] [varchar](100) NULL,
	[DesignationId] [int] NULL,
	[HourlyRate] [numeric](18, 2) NULL,
	[EfficiencyFactor] [bit] NULL,
	[IsActive] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ResourceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [imagema1_docuser].[tblAllocation]  WITH CHECK ADD  CONSTRAINT [CK_tblAllocation_TaskComplexity] CHECK  (([TaskComplexity]>=(1) AND [TaskComplexity]<=(10)))
GO
ALTER TABLE [imagema1_docuser].[tblAllocation] CHECK CONSTRAINT [CK_tblAllocation_TaskComplexity]
GO
/****** Object:  StoredProcedure [imagema1_docuser].[sp_BulkSaveAllocations]    Script Date: 22/09/2026 03:59:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [imagema1_docuser].[sp_BulkSaveAllocations]
    @Allocations udt_AllocationList READONLY
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO tblAllocation (ProjectId, ResourceId, [date], HourseWorked, TaskComplexity)
    SELECT ProjectId, ResourceId, [date], HourseWorked, TaskComplexity
    FROM @Allocations;
END;
GO
/****** Object:  StoredProcedure [imagema1_docuser].[sp_GetProjectCostReport]    Script Date: 22/09/2026 03:59:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [imagema1_docuser].[sp_GetProjectCostReport]
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH CostCalc AS
    (
        SELECT 
            p.ProjectId,
            p.ProjectName,
            p.ApprovedBudget,
            ISNULL(SUM(a.HourseWorked * r.HourlyRate 
                * ((CAST(a.TaskComplexity AS NUMERIC(18,2)) / 10.0) + 1.0)
                * (CASE WHEN r.EfficiencyFactor = 1 THEN 1.0 ELSE 0.0 END)
            ), 0) AS ActualCost
        FROM tblProject p
        LEFT JOIN tblAllocation a ON p.ProjectId = a.ProjectId
        LEFT JOIN tblResource r ON a.ResourceId = r.ResourceId
        GROUP BY p.ProjectId, p.ProjectName, p.ApprovedBudget
    )
    SELECT 
        ProjectId,
        ProjectName,
        ApprovedBudget,
        CAST(ActualCost AS NUMERIC(18,2)) AS ActualCost,
        CAST((ApprovedBudget - ActualCost) AS NUMERIC(18,2)) AS CostVariance
    FROM CostCalc
    ORDER BY ProjectName;
END;
GO
/****** Object:  StoredProcedure [imagema1_docuser].[sp_GetProjects]    Script Date: 22/09/2026 03:59:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [imagema1_docuser].[sp_GetProjects]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProjectId, ProjectName, StartSate, EndDate, EstimatedBudget, ApprovedBudget, RiskFactor 
    FROM tblProject ORDER BY ProjectId DESC;
END;
GO
/****** Object:  StoredProcedure [imagema1_docuser].[sp_GetResources]    Script Date: 22/09/2026 03:59:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [imagema1_docuser].[sp_GetResources]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.ResourceId, r.FullName, r.DesignationId, d.Designation AS DesignationName, 
           r.HourlyRate, r.EfficiencyFactor, r.IsActive
    FROM tblResource r
    LEFT JOIN tblDesignation d ON r.DesignationId = d.DesignationId
    ORDER BY r.ResourceId DESC;
END;
GO
/****** Object:  StoredProcedure [imagema1_docuser].[sp_SaveOrUpdateProject]    Script Date: 22/09/2026 03:59:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [imagema1_docuser].[sp_SaveOrUpdateProject]
    @ProjectId INT,
    @ProjectName NVARCHAR(100),
    @StartSate DATE,
    @EndDate DATE,
    @EstimatedBudget NUMERIC(18,2),
    @ApprovedBudget NUMERIC(18,2),
    @RiskFactor BIT
AS
BEGIN
    SET NOCOUNT ON;
    IF @ProjectId = 0
    BEGIN
        INSERT INTO tblProject (ProjectName, StartSate, EndDate, EstimatedBudget, ApprovedBudget, RiskFactor)
        VALUES (@ProjectName, @StartSate, @EndDate, @EstimatedBudget, @ApprovedBudget, @RiskFactor);
    END
    ELSE
    BEGIN
        UPDATE tblProject 
        SET ProjectName = @ProjectName,
            StartSate = @StartSate,
            EndDate = @EndDate,
            EstimatedBudget = @EstimatedBudget,
            ApprovedBudget = @ApprovedBudget,
            RiskFactor = @RiskFactor
        WHERE ProjectId = @ProjectId;
    END
END;
GO
/****** Object:  StoredProcedure [imagema1_docuser].[sp_SaveOrUpdateResource]    Script Date: 22/09/2026 03:59:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [imagema1_docuser].[sp_SaveOrUpdateResource]
    @ResourceId INT,
    @FullName VARCHAR(100),
    @DesignationId INT,
    @HourlyRate NUMERIC(18,2),
    @EfficiencyFactor BIT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;
    IF @ResourceId = 0
    BEGIN
        INSERT INTO tblResource (FullName, DesignationId, HourlyRate, EfficiencyFactor, IsActive)
        VALUES (@FullName, @DesignationId, @HourlyRate, @EfficiencyFactor, @IsActive);
    END
    ELSE
    BEGIN
        UPDATE tblResource 
        SET FullName = @FullName,
            DesignationId = @DesignationId,
            HourlyRate = @HourlyRate,
            EfficiencyFactor = @EfficiencyFactor,
            IsActive = @IsActive
        WHERE ResourceId = @ResourceId;
    END
END;
GO
