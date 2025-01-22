using System;
using System.Net.Http;

namespace DotNetApp.Utils
{
    public static class HttpClientHelper
    {
        public static HttpClient CreateHttpClient()
        {
            return new HttpClient { Timeout = TimeSpan.FromSeconds(10) };
        }
    }
}
