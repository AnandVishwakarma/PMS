using System;
using System.Collections.Generic;

namespace WebApplication1.Models
{
    public class ProjectModel
    {
        public int ProjectId { get; set; }
        public string ProjectName { get; set; } = string.Empty;
        public DateTime StartSate { get; set; } = DateTime.Today;
        public DateTime EndDate { get; set; } = DateTime.Today.AddMonths(1);
        public decimal EstimatedBudget { get; set; }
        public decimal ApprovedBudget { get; set; }
        public bool RiskFactor { get; set; }
    }

    public class ResourceModel
    {
        public int ResourceId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public int DesignationId { get; set; }
        public string DesignationName { get; set; } = string.Empty;
        public decimal HourlyRate { get; set; }
        public bool EfficiencyFactor { get; set; }
        public bool IsActive { get; set; }
    }

    public class DesignationModel
    {
        public int DesignationId { get; set; }
        public string Designation { get; set; } = string.Empty;
    }

    public class AllocationItemModel
    {
        public int ProjectId { get; set; }
        public string ProjectName { get; set; } = string.Empty;
        public int ResourceId { get; set; }
        public string ResourceName { get; set; } = string.Empty;
        public DateTime Date { get; set; }
        public decimal HourseWorked { get; set; }
        public int TaskComplexity { get; set; }
    }

    public class ProjectCostReportModel
    {
        public int ProjectId { get; set; }
        public string ProjectName { get; set; } = string.Empty;
        public decimal ActualCost { get; set; }
        public decimal ApprovedBudget { get; set; }
        public decimal CostVariance { get; set; }
    }
}