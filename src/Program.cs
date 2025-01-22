using DotNetApp.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder
    .Services.AddHttpClient<ExternalService>()
    .ConfigureHttpClient(client => client.Timeout = TimeSpan.FromSeconds(10));

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.MapControllers();

app.Run("http://localhost:8080");
