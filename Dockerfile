FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY src/donet-app.csproj ./src/donet-app.csproj
RUN dotnet restore ./src/donet-app.csproj

COPY src ./src
RUN dotnet publish ./src -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app


------------------------------------------
# Instalar dependências necessárias (curl e unzip)
RUN apt-get update && apt-get install -y curl unzip && apt-get clean
# Instalar o agente do OpenTelemetry
ARG OTEL_VERSION=1.9.0
ADD https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation/releases/download/v${OTEL_VERSION}/otel-dotnet-auto-install.sh otel-dotnet-auto-install.sh
RUN chmod +x otel-dotnet-auto-install.sh && \
    OTEL_DOTNET_AUTO_HOME="/otel-dotnet-auto" sh otel-dotnet-auto-install.sh

# Trocar para o nome da APP
ENV OTEL_SERVICE_NAME="dotnet-app" 
# Trocar para o nome da APP e o Ambiente
ENV OTEL_RESOURCE_ATTRIBUTES="service.name=dotnet-app,environment=production"

ENV OTEL_DOTNET_AUTO_HOME=/otel-dotnet-auto
ENV DOTNET_STARTUP_HOOKS=/otel-dotnet-auto/net/OpenTelemetry.AutoInstrumentation.StartupHook.dll
ENV OTEL_EXPORTER_OTLP_ENDPOINT="http://apm.internal.finance.com:4318"
------------------------------------------

COPY --from=build /app .

EXPOSE 8080
ENTRYPOINT ["dotnet", "donet-app.dll"]
