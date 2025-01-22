using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using DotNetApp.Utils;

namespace DotNetApp.Services
{
    public class ExternalService
    {
        private readonly HttpClient _httpClient;

        public ExternalService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<object> FetchExternalServiceAsync(string url)
        {
            try
            {
                var response = await _httpClient.GetAsync(url);

                if (!response.IsSuccessStatusCode)
                {
                    return null;
                }

                var json = await response.Content.ReadAsStringAsync();
                return JsonSerializer.Deserialize<object>(json);
            }
            catch
            {
                return null;
            }
        }
    }
}
