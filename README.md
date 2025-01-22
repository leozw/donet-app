# Instrumentação Automática de Aplicativos .NET com OpenTelemetry

Este guia fornece um exemplo completo para instrumentar aplicações .NET usando OpenTelemetry com zero alterações no código. Basta configurar o agente através de um Dockerfile e utilizar as variáveis de ambiente necessárias.

---

## 1. **Dockerfile para Aplicações .NET**

✨ Use o seguinte Dockerfile como base para construir sua imagem Docker com o agente OpenTelemetry integrado ⛏:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY donet-app.csproj ./donet-app.csproj
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Instalar dependências necessárias (curl e unzip)
RUN apt-get update && apt-get install -y curl unzip && apt-get clean

# Instalar o agente do OpenTelemetry
ARG OTEL_VERSION=1.9.0
ADD https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation/releases/download/v${OTEL_VERSION}/otel-dotnet-auto-install.sh otel-dotnet-auto-install.sh
RUN chmod +x otel-dotnet-auto-install.sh && \
    OTEL_DOTNET_AUTO_HOME="/otel-dotnet-auto" sh otel-dotnet-auto-install.sh

# Definir o caminho para o startup hook
ENV OTEL_DOTNET_AUTO_HOME=/otel-dotnet-auto
ENV DOTNET_STARTUP_HOOKS=/otel-dotnet-auto/net/OpenTelemetry.AutoInstrumentation.StartupHook.dll

COPY --from=build /app .

EXPOSE 8080
ENTRYPOINT ["dotnet", "donet-app.dll"]
```

### Como Usar Este Dockerfile

1. Substitua `donet-app.csproj` pelo nome do arquivo de projeto da sua aplicação .NET.
2. Construa sua imagem Docker:

   ```
   docker build -t sua-imagem-dotnet:latest .
   ```

3. Publique a imagem no seu repositório Docker:

   ```
   docker push sua-imagem-dotnet:latest
   ```

---

## 2. **Configuração no Kubernetes**

Aqui está um exemplo de como implantar sua aplicação instrumentada no Kubernetes:

### Manifesto de Implantção

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: donet-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: donet-app
  template:
    metadata:
      labels:
        app: donet-app
    spec:
      containers:
        - name: donet-app
          image: sua-imagem-dotnet:latest
          ports:
            - containerPort: 8080
          env:
            - name: OTEL_SERVICE_NAME
              value: "dotnet-app"
            - name: OTEL_RESOURCE_ATTRIBUTES
              value: "service.name=donet-app,service.version=1.0.0"
            - name: OTEL_EXPORTER_OTLP_ENDPOINT
              value: "http://opentelemetry-collector:4317"
```

Certifique-se de ter um OpenTelemetry Collector configurado para receber os dados no endpoint http://opentelemetry-collector:4317. Esses dados serão enviados para a stack LGTM e podem ser visualizados diretamente no Grafana, garantindo insights valiosos sobre a sua aplicação.

---

## 3. **Configuração no Amazon ECS**

Aqui está um exemplo de como configurar sua aplicação no ECS (Elastic Container Service):

### Definição de Tarefa do ECS

```json
{
  "containerDefinitions": [
    {
      "name": "donet-app",
      "image": "sua-imagem-dotnet:latest",
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "environment": [
        {
          "name": "OTEL_SERVICE_NAME",
          "value": "dotnet-app"
        },
        {
          "name": "OTEL_RESOURCE_ATTRIBUTES",
          "value": "service.name=donet-app,service.version=1.0.0"
        },
        {
          "name": "OTEL_EXPORTER_OTLP_ENDPOINT",
          "value": "http://opentelemetry-collector:4317"
        }
      ]
    }
  ],
  "family": "donet-app"
}
```

---

## 4. **Testando a Instrumentação**

### Verifique se os dados estão chegando ao OpenTelemetry Collector

1. Suba o OpenTelemetry Collector localmente ou no cluster.
2. Verifique os logs do Collector para confirmar o recebimento dos dados.

### Ferramentas Recomendadas

- **Grafana:** Para visualizar traces, logs e métricas coletadas.

---

## 5. **Customizações Avançadas**

Se você precisar adicionar atributos customizados ou ajustar as exportações, basta configurar as variáveis de ambiente no manifesto do Kubernetes ou na definição de tarefa do ECS.

Exemplo de configuração adicional:

```yaml
env:
  - name: OTEL_LOG_LEVEL
    value: "debug"
  - name: OTEL_TRACES_SAMPLER
    value: "parentbased_always_on"
```

---

## Conclusão

Com o exemplo acima, você pode instrumentar qualquer aplicação .NET com OpenTelemetry sem alterar o código. A configuração simples do Dockerfile e os exemplos para Kubernetes e ECS facilitam a integração em diversos ambientes.

Se tiver dúvidas ou precisar de suporte adicional, entre em contato com nossa equipe 🤝 ou consulte a [documentação oficial do OpenTelemetry](https://opentelemetry.io/docs/zero-code/net/) ℹ️.
