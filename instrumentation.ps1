$moduleUrl = "https://github.com/elven-observability/opentelemetry-dotnet-instrumentation/releases/download/v1.0.0/OpenTelemetry.DotNet.Auto.psm1"
$modulePath = Join-Path $env:TEMP "OpenTelemetry.DotNet.Auto.psm1"

Invoke-WebRequest -Uri $moduleUrl -OutFile $modulePath -UseBasicParsing
Import-Module $modulePath

$installDir = "C:\otel-dotnet-auto"
Install-OpenTelemetryCore -InstallDir $installDir

$serviceName = "dotnet-app"
Register-OpenTelemetryForCurrentSession -OTelServiceName $serviceName

[Environment]::SetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT", "http://apm.internal.finance.com:4318", [System.EnvironmentVariableTarget]::Machine)

Write-Host "OpenTelemetry instalado e configurado com sucesso!"