using System.Threading.Tasks;
using DotNetApp.Services;
using Microsoft.AspNetCore.Mvc;

namespace DotNetApp.Controllers
{
    [ApiController]
    [Route("external-service")]
    public class ExternalController : ControllerBase
    {
        private readonly ExternalService _externalService;

        public ExternalController(ExternalService externalService)
        {
            _externalService = externalService;
        }

        [HttpGet("1")]
        public async Task<IActionResult> GetService1()
        {
            var result = await _externalService.FetchExternalServiceAsync(
                "https://jsonplaceholder.typicode.com/posts/1"
            );
            if (result == null)
                return StatusCode(500, new { error = "Failed to fetch data" });

            return Ok(new { data = result });
        }

        [HttpGet("2")]
        public async Task<IActionResult> GetService2()
        {
            var result = await _externalService.FetchExternalServiceAsync(
                "https://jsonplaceholder.typicode.com/users/1"
            );
            if (result == null)
                return StatusCode(500, new { error = "Failed to fetch data" });

            return Ok(new { data = result });
        }

        [HttpGet("3")]
        public async Task<IActionResult> GetService3()
        {
            var result = await _externalService.FetchExternalServiceAsync(
                "https://jsonplaceholder.typicode.com/albums/1"
            );
            if (result == null)
                return StatusCode(500, new { error = "Failed to fetch data" });

            return Ok(new { data = result });
        }
    }
}
