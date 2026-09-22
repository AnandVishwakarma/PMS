using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApplication1.Models;

namespace WebApplication1.Data
{
    public class AdoDataAccess
    {
        private readonly string _connectionString;

        public AdoDataAccess(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DocDb")
                ?? throw new InvalidOperationException("Connection string 'DocDb' not configured.");
        }

        
        public List<ProjectModel> GetProjects()
        {
            var list = new List<ProjectModel>();
            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand("sp_GetProjects", conn) { CommandType = CommandType.StoredProcedure })
            {
                conn.Open();
                using var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    list.Add(new ProjectModel
                    {
                        ProjectId = Convert.ToInt32(reader["ProjectId"]),
                        ProjectName = reader["ProjectName"].ToString()!,
                        StartSate = Convert.ToDateTime(reader["StartSate"]),
                        EndDate = Convert.ToDateTime(reader["EndDate"]),
                        EstimatedBudget = Convert.ToDecimal(reader["EstimatedBudget"]),
                        ApprovedBudget = Convert.ToDecimal(reader["ApprovedBudget"]),
                        RiskFactor = Convert.ToBoolean(reader["RiskFactor"])
                    });
                }
            }
            return list;
        }

        public void SaveOrUpdateProject(ProjectModel p)
        {
            using var conn = new SqlConnection(_connectionString);
            using var cmd = new SqlCommand("sp_SaveOrUpdateProject", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@ProjectId", p.ProjectId);
            cmd.Parameters.AddWithValue("@ProjectName", p.ProjectName);
            cmd.Parameters.AddWithValue("@StartSate", p.StartSate.Date);
            cmd.Parameters.AddWithValue("@EndDate", p.EndDate.Date);
            cmd.Parameters.AddWithValue("@EstimatedBudget", p.EstimatedBudget);
            cmd.Parameters.AddWithValue("@ApprovedBudget", p.ApprovedBudget);
            cmd.Parameters.AddWithValue("@RiskFactor", p.RiskFactor);
            conn.Open();
            cmd.ExecuteNonQuery();
        }

        
        public List<ResourceModel> GetResources()
        {
            var list = new List<ResourceModel>();
            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand("sp_GetResources", conn) { CommandType = CommandType.StoredProcedure })
            {
                conn.Open();
                using var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    list.Add(new ResourceModel
                    {
                        ResourceId = Convert.ToInt32(reader["ResourceId"]),
                        FullName = reader["FullName"].ToString()!,
                        DesignationId = Convert.ToInt32(reader["DesignationId"]),
                        DesignationName = reader["DesignationName"]?.ToString() ?? "",
                        HourlyRate = Convert.ToDecimal(reader["HourlyRate"]),
                        EfficiencyFactor = Convert.ToBoolean(reader["EfficiencyFactor"]),
                        IsActive = Convert.ToBoolean(reader["IsActive"])
                    });
                }
            }
            return list;
        }

        public List<DesignationModel> GetDesignations()
        {
            var list = new List<DesignationModel>();
            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand("SELECT DesignationId, Designation FROM tblDesignation", conn))
            {
                conn.Open();
                using var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    list.Add(new DesignationModel
                    {
                        DesignationId = Convert.ToInt32(reader["DesignationId"]),
                        Designation = reader["Designation"].ToString()!
                    });
                }
            }
            return list;
        }

        public void SaveOrUpdateResource(ResourceModel r)
        {
            using var conn = new SqlConnection(_connectionString);
            using var cmd = new SqlCommand("sp_SaveOrUpdateResource", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@ResourceId", r.ResourceId);
            cmd.Parameters.AddWithValue("@FullName", r.FullName);
            cmd.Parameters.AddWithValue("@DesignationId", r.DesignationId);
            cmd.Parameters.AddWithValue("@HourlyRate", r.HourlyRate);
            cmd.Parameters.AddWithValue("@EfficiencyFactor", r.EfficiencyFactor);
            cmd.Parameters.AddWithValue("@IsActive", r.IsActive);
            conn.Open();
            cmd.ExecuteNonQuery();
        }

        
        public void BulkSaveAllocations(List<AllocationItemModel> allocations)
        {
            var dt = new DataTable();
            dt.Columns.Add("ProjectId", typeof(int));
            dt.Columns.Add("ResourceId", typeof(int));
            dt.Columns.Add("date", typeof(DateTime));
            dt.Columns.Add("HourseWorked", typeof(decimal));
            dt.Columns.Add("TaskComplexity", typeof(int));

            foreach (var item in allocations)
            {
                dt.Rows.Add(item.ProjectId, item.ResourceId, item.Date.Date, item.HourseWorked, item.TaskComplexity);
            }

            using var conn = new SqlConnection(_connectionString);
            using var cmd = new SqlCommand("sp_BulkSaveAllocations", conn) { CommandType = CommandType.StoredProcedure };
            var param = cmd.Parameters.AddWithValue("@Allocations", dt);
            param.SqlDbType = SqlDbType.Structured;
            param.TypeName = "udt_AllocationList";

            conn.Open();
            cmd.ExecuteNonQuery();
        }

        public List<ProjectCostReportModel> GetProjectCostReport()
        {
            var list = new List<ProjectCostReportModel>();
            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand("sp_GetProjectCostReport", conn) { CommandType = CommandType.StoredProcedure })
            {
                conn.Open();
                using var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    list.Add(new ProjectCostReportModel
                    {
                        ProjectId = Convert.ToInt32(reader["ProjectId"]),
                        ProjectName = reader["ProjectName"].ToString()!,
                        ActualCost = Convert.ToDecimal(reader["ActualCost"]),
                        ApprovedBudget = Convert.ToDecimal(reader["ApprovedBudget"]),
                        CostVariance = Convert.ToDecimal(reader["CostVariance"])
                    });
                }
            }
            return list;
        }   
    }
}