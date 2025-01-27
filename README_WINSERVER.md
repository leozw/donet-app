# **Configuração das Variáveis de Ambiente para Instrumentação com OpenTelemetry**

Este guia descreve como configurar as variáveis de ambiente necessárias para a instrumentação com OpenTelemetry, utilizando valores carregados dinamicamente do AWS Systems Manager Parameter Store.

## **Estrutura Esperada do `appsettings.json`**

Certifique-se de que o arquivo `appsettings.json` inclua as chaves do Parameter Store que contêm os valores necessários para a instrumentação:

```json
{
  "AWS": {
    "Region": "us-east-1"
  },
  "ParameterStore": {
    "Keys": [
      "/dotnet-app/OTEL_SERVICE_NAME",
      "/dotnet-app/OTEL_RESOURCE_ATTRIBUTES"
    ]
  }
}

```

### **Parâmetros Recomendados**

- **`/dotnet-app/OTEL_SERVICE_NAME`**: Nome do serviço para identificação no OpenTelemetry.
- **`/dotnet-app/OTEL_RESOURCE_ATTRIBUTES`**: Atributos adicionais para recursos no OpenTelemetry, como o ambiente e o nome do serviço.

## **Parâmetros Necessários no Parameter Store**

Crie os seguintes parâmetros no AWS Systems Manager Parameter Store para habilitar a instrumentação:

```bash
aws ssm put-parameter --name "/dotnet-app/OTEL_SERVICE_NAME" --value "my-app" --type "String"
aws ssm put-parameter --name "/dotnet-app/OTEL_RESOURCE_ATTRIBUTES" --value "service.name=my-app,environment=production" --type "String"

```

## **Notas Importantes**

1. **Variáveis Necessárias para o OpenTelemetry**:
    - **`OTEL_SERVICE_NAME`**: Identifica o nome do serviço na instrumentação.
    - **`OTEL_RESOURCE_ATTRIBUTES`**: Define os atributos do serviço, como `service.name` e `environment`.
2. **Permissões do IAM**:
    - Certifique-se de que a instância ou o serviço que executa a aplicação tenha permissões adequadas para acessar os parâmetros no Parameter Store.
3. **Integração Simples**:
    - As variáveis carregadas dinamicamente são lidas diretamente pelo agente do OpenTelemetry, sem necessidade de alterações adicionais.

Após configurar os parâmetros e o código, a instrumentação será automaticamente configurada para cada serviço.

---

# **Parte 2: Instrumentação Automática com OpenTelemetry**

Nesta etapa, você aprenderá como realizar a instrumentação automática das aplicações .NET utilizando o script `instrumentation.ps1`.

## **Requisitos**

1. **Preparação da Aplicação**: Certifique-se de que a aplicação foi configurada conforme a [Parte 1](https://www.notion.so/Hyper-184635bb48fb801cb0ccf47802f502cf?pvs=21).
2. **Acesso Administrador**: Execute o script como **Administrador**.
3. **Script de Instrumentação**: O script `instrumentation.ps1` está disponível na raiz do repositório.

## **Passos para Instrumentação**

### **1. Baixe e Execute o Script de Instrumentação**

Execute os comandos abaixo no PowerShell:

```powershell
# Caminho padrão onde o script será salvo
$scriptPath = "C:\Users\Administrator\instrumentation.ps1"

# Baixe o script diretamente do repositório
Invoke-WebRequest -Uri "https://github.com/elven-observability/opentelemetry-dotnet-instrumentation/releases/download/v1.0.0/instrumentation.ps1" -OutFile $scriptPath

# Execute o script como Administrador
PowerShell -ExecutionPolicy Bypass -File $scriptPath

```

### **2. O que o Script Faz**

O script executa as seguintes ações automaticamente:

- **Instalação do OpenTelemetry Agent** no caminho padrão: `C:\otel-dotnet-auto`.
- **Registro da Aplicação** com o nome padrão: `dotnet-app`.
- **Configuração do Endpoint OTLP** para envio de dados: `http://apm.internal.finance.com:4318`.

### **3. Código do Script**

```powershell
# Script de Instrumentação OpenTelemetry
$moduleUrl = "https://github.com/elven-observability/opentelemetry-dotnet-instrumentation/releases/download/v1.0.0/OpenTelemetry.DotNet.Auto.psm1"
$modulePath = Join-Path $env:TEMP "OpenTelemetry.DotNet.Auto.psm1"

# Baixe e importe o módulo
Invoke-WebRequest -Uri $moduleUrl -OutFile $modulePath -UseBasicParsing
Import-Module $modulePath

# Instale o OpenTelemetry Agent no caminho padrão
$installDir = "C:\otel-dotnet-auto"
Install-OpenTelemetryCore -InstallDir $installDir

# Registre a aplicação
$serviceName = "dotnet-app"
Register-OpenTelemetryForCurrentSession -OTelServiceName $serviceName

# Configure o Endpoint OTLP
[Environment]::SetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT", "http://apm.internal.finance.com:4318", [System.EnvironmentVariableTarget]::Machine)

Write-Host "OpenTelemetry instalado e configurado com sucesso!"

```

### **4. Confirmação**

Após a execução do script, você verá a mensagem:

```
OpenTelemetry instalado e configurado com sucesso!

```

### **5. Caminhos Padrão**

Por padrão, o script utiliza os seguintes caminhos:

- **Caminho do Script**: `C:\Users\Administrator\instrumentation.ps1`
- **Diretório de Instalação do OpenTelemetry**: `C:\otel-dotnet-auto`
