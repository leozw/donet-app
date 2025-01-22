# 💡 OpenTelemetry Agent Installation Script
# This script installs and configures the OpenTelemetry .NET agent on a Windows machine.

# 🔧 Variables
$otelVersion = "1.9.0"
$otelInstallDir = "C:\otel-dotnet-auto"
$otelDownloadUrl = "https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation/releases/download/v$otelVersion/opentelemetry-dotnet-instrumentation-windows.zip"
$otelZipFile = "C:\otel-dotnet-auto.zip"
$servicename = "dotnet-app"
$otelendpoint = "http://54.91.135.133:4318"
$resouceattibutes = "service.name=dotnet-app,environment=production"

function Show-ErrorAndExit {
    param ([string]$message)
    Write-Error "❌ $message"
    exit 1
}

Write-Host "📥 Downloading the OpenTelemetry agent..."
try {
    Invoke-WebRequest -Uri $otelDownloadUrl -OutFile $otelZipFile -ErrorAction Stop
    Write-Host "✅ Download completed: $otelZipFile"
} catch {
    Show-ErrorAndExit "Failed to download the OpenTelemetry agent: $_"
}

Write-Host "📂 Extracting the agent to $otelInstallDir..."
try {
    Expand-Archive -Path $otelZipFile -DestinationPath $otelInstallDir -Force
    Write-Host "✅ Agent extracted successfully to $otelInstallDir"
    Remove-Item -Path $otelZipFile -Force
} catch {
    Show-ErrorAndExit "Failed to extract the agent files: $_"
}

Write-Host "⚙️ Configuring environment variables..."
try {
    [Environment]::SetEnvironmentVariable("OTEL_DOTNET_AUTO_HOME", $otelInstallDir, [System.EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("DOTNET_STARTUP_HOOKS", "$otelInstallDir\net\OpenTelemetry.AutoInstrumentation.StartupHook.dll", [System.EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("DOTNET_SHARED_STORE", "$otelInstallDir\store", [System.EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("OTEL_SERVICE_NAME", $servicename, [System.EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT", $otelendpoint, [System.EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("OTEL_RESOURCE_ATTRIBUTES", $resouceattibutes, [System.EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("OTEL_TRACES_EXPORTER", "true", [System.EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("OTEL_METRICS_EXPORTER", "true", [System.EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("OTEL_LOGS_EXPORTER", "true", [System.EnvironmentVariableTarget]::Machine)
    Write-Host "✅ Environment variables configured successfully."
} catch {
    Show-ErrorAndExit "Failed to configure environment variables: $_"
}

Write-Host "🔐 Configuring Windows Firewall to allow OTLP endpoint communication..."
try {
    New-NetFirewallRule -DisplayName "OpenTelemetry OTLP" -Direction Outbound -Action Allow -Protocol TCP -RemoteAddress Any -RemotePort 4317
    Write-Host "✅ Firewall rule configured successfully."
} catch {
    Show-ErrorAndExit "Failed to configure the firewall: $_"
}

Write-Host "🛠️ Verifying if .NET Runtime and dependencies are installed..."
try {
    $dotnetVersion = &dotnet --list-runtimes | Select-String -Pattern "Microsoft.AspNetCore.App 8.0"
    if (-not $dotnetVersion) {
        Show-ErrorAndExit "❌ .NET Runtime 8.0 is not installed. Please install it before proceeding."
    }
    Write-Host "✅ All required dependencies are installed."
} catch {
    Show-ErrorAndExit "Failed to verify dependencies: $_"
}

Write-Host "🎉 Setup completed successfully!"
Write-Host "👉 To apply the changes, restart the application process or log out and log back in to reload the environment variables."
Write-Host "⚠️ NOTE: No machine restart is required. Just ensure the application picks up the new environment variables."
