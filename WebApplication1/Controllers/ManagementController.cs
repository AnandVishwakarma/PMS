using Microsoft.AspNetCore.Mvc;
using WebApplication1.Data;
using WebApplication1.Models;

namespace WebApplication1.Controllers
{
    public class ManagementController : Controller
    {
        private readonly AdoDataAccess _db;

        public ManagementController(AdoDataAccess db)
        {
            _db = db;
        }

        
        [HttpGet]
        public IActionResult Project()
        {
            ViewBag.Projects = _db.GetProjects();
            return View(new ProjectModel());
        }

        [HttpPost]
        public IActionResult SaveProject(ProjectModel model)
        {
            if (ModelState.IsValid)
            {
                _db.SaveOrUpdateProject(model);
            }
            return RedirectToAction(nameof(Project));
        }

        
        [HttpGet]
        public IActionResult Resource()
        {
            ViewBag.Designations = _db.GetDesignations();
            ViewBag.Resources = _db.GetResources();
            return View(new ResourceModel());
        }

        [HttpPost]
        public IActionResult SaveResource(ResourceModel model)
        {
            if (ModelState.IsValid)
            {
                _db.SaveOrUpdateResource(model);
            }
            return RedirectToAction(nameof(Resource));
        }

        
        [HttpGet]
        public IActionResult Allocation()
        {
            ViewBag.Projects = _db.GetProjects();
            ViewBag.Resources = _db.GetResources();
            return View();
        }

        [HttpPost]
        public IActionResult FinalSubmitAllocation([FromBody] List<AllocationItemModel> allocations)
        {
            if (allocations == null || allocations.Count == 0)
            {
                return BadRequest("No allocation data to submit.");
            }

            _db.BulkSaveAllocations(allocations);
            return Json(new { success = true, message = $"{allocations.Count} allocation record(s) saved successfully!" });
        }

        [HttpGet]
        public IActionResult CostReport()
        {
            var reportData = _db.GetProjectCostReport();
            return View(reportData);
        }
    }
}