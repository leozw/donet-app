using System.Threading.Tasks;
using DotNetApp.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace DotNetApp.Controllers
{
    [ApiController]
    [Route("external-service")]
    public class ExternalController : ControllerBase
    {
        private readonly ExternalService _externalService;
        private readonly ILogger<ExternalController> _logger;

        public ExternalController(ExternalService externalService, ILogger<ExternalController> logger)
        {
            _externalService = externalService;
            _logger = logger;
        }

        [HttpGet("1")]
        public async Task<IActionResult> GetService1()
        {
            _logger.LogInformation("📥 Rota GET /external-service/1 acionada");
            var result = await _externalService.FetchExternalServiceAsync(
                "https://jsonplaceholder.typicode.com/posts/1"
            );

            if (result == null)
            {
                _logger.LogError("❌ Falha ao buscar dados do serviço externo 1");
                return StatusCode(500, new { error = "Failed to fetch data" });
            }

            _logger.LogInformation("✅ Dados recebidos do serviço externo 1");
            return Ok(new { data = result });
        }

        [HttpGet("2")]
        public async Task<IActionResult> GetService2()
        {
            _logger.LogInformation("📥 Rota GET /external-service/2 acionada");
            var result = await _externalService.FetchExternalServiceAsync(
                "https://jsonplaceholder.typicode.com/users/1"
            );

            if (result == null)
            {
                _logger.LogError("❌ Falha ao buscar dados do serviço externo 2");
                return StatusCode(500, new { error = "Failed to fetch data" });
            }

            _logger.LogInformation("✅ Dados recebidos do serviço externo 2");
            return Ok(new { data = result });
        }

        [HttpGet("3")]
        public async Task<IActionResult> GetService3()
        {
            _logger.LogInformation("📥 Rota GET /external-service/3 acionada");
            var result = await _externalService.FetchExternalServiceAsync(
                "https://jsonplaceholder.typicode.com/albums/1"
            );

            if (result == null)
            {
                _logger.LogError("❌ Falha ao buscar dados do serviço externo 3");
                return StatusCode(500, new { error = "Failed to fetch data" });
            }

            _logger.LogInformation("✅ Dados recebidos do serviço externo 3");
            return Ok(new { data = result });
        }
    }
}
