using DotNetApp.Services;
using LokiConsoleLogger;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddLogging(logging =>
{
    logging.ClearProviders();
    logging.AddConsole();
    logging.AddLokiLogger(options =>
    {
        options.Url = "https://loki.elvenobservability.com/loki/api/v1/push";
        options.AuthToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJlbHZlbi1sZ3RtLWp3dCIsInN1YiI6IjEyMzQ1Njc4OTAiLCJuYW1lIjoiRWx2ZW4gTEdUTSIsImFkbWluIjp0cnVlLCJpYXQiOjE3MjY3Njc4NTd9.GJRvXKOD91lndv6YuPaBLzsicxuLYd5iTYzH_D24X3w";
        options.TenantId = "elven-logs";
        options.AppName = "dotnet-app";
    });
});

builder.Services.AddControllers();
builder
    .Services.AddHttpClient<ExternalService>()
    .ConfigureHttpClient(client => client.Timeout = TimeSpan.FromSeconds(10));

var app = builder.Build();

var logger = app.Services.GetRequiredService<ILogger<Program>>();
logger.LogInformation("🚀 API iniciada no ambiente {Environment}", app.Environment.EnvironmentName);

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.MapControllers();

app.Run("http://localhost:8080");
