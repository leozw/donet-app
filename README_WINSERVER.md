# Configuração das Variáveis de Ambiente para Instrumentação com OpenTelemetry

Este guia descreve como configurar as variáveis de ambiente necessárias para a instrumentação com OpenTelemetry, utilizando valores carregados dinamicamente do AWS Systems Manager Parameter Store.

## Estrutura Esperada do `appsettings.json`

Certifique-se de que o arquivo `appsettings.json` inclua as chaves do Parameter Store que contêm os valores necessários para a instrumentação:

```json
json
CopiarEditar
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

- **`/dotnet-app/OTEL_SERVICE_NAME`**: Nome do serviço para identificação no OpenTelemetry.
- **`/dotnet-app/OTEL_RESOURCE_ATTRIBUTES`**: Atributos adicionais para recursos no OpenTelemetry, como o ambiente.

## Parâmetros Necessários no Parameter Store

Crie os seguintes parâmetros no AWS Systems Manager Parameter Store para habilitar a instrumentação:

```bash
aws ssm put-parameter --name "/dotnet-app/OTEL_SERVICE_NAME" --value "my-app" --type "String"
aws ssm put-parameter --name "/dotnet-app/OTEL_RESOURCE_ATTRIBUTES" --value "service.name=my-app,environment=production" --type "String"
```

## Notas Importantes

1. **Variáveis Necessárias para o OpenTelemetry**:
    - **`OTEL_SERVICE_NAME`**: Identifica o nome do serviço na instrumentação.
    - **`OTEL_RESOURCE_ATTRIBUTES`**: Define os atributos do serviço (e.g., `service.name`, `environment`).
2. **Permissões do IAM**:
    - Garanta que a instância ou o serviço que executa a aplicação tenha permissões adequadas para acessar os parâmetros no Parameter Store.
3. **Integração Simples**:
    - As variáveis carregadas dinamicamente são lidas diretamente pelo agente do OpenTelemetry sem necessidade de alterações adicionais.

Após configurar os parâmetros e o código, a instrumentação será automaticamente configurada para cada serviço.