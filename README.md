# VMGriffes — E-commerce de Roupas

Plataforma de e-commerce completa construida com **9 microsservicos Quarkus**, **Angular 19** e **Caddy API Gateway**, projetada para deploy na **Oracle Cloud Free Tier** ($0/mes). 7 servicos compilam para **GraalVM Native Image** com inicializacao instantanea.

## Stack Tecnologica

| Categoria | Tecnologia |
|---|---|
| Linguagem | Java 21 LTS |
| Framework | Quarkus 3.18.x |
| Frontend | Angular 19 (Standalone + Signals) |
| API Gateway | Caddy 2.9 (HTTPS automatico, forward_auth, rate limit) |
| Banco de Dados | PostgreSQL 16 (schemas isolados) |
| Message Broker | Upstash Kafka (serverless) / Kafka 3.9 (dev) |
| Imagens | Cloudinary Free Tier (Upload Widget + CDN) |
| Pagamentos | Asaas (Pix, boleto, cartao de credito) |
| Frete | Melhor Envio API |
| Notificacoes | Quarkus Mailer (SMTP) |
| Testes | JUnit 5, REST Assured, Testcontainers |
| Build | Maven (multi-module) |
| Native Compiler | GraalVM / Mandrel (7 servicos) |
| CI/CD | GitHub Actions (self-hosted ARM runner) |
| Deploy | Oracle Cloud Free Tier ARM (4 OCPU, 24GB RAM) |
| Tracing | OpenTelemetry + Zipkin |

## Decisoes Tecnicas

| Decisao | Implementacao | Motivo |
|---|---|---|
| 7 Native + 2 JVM | IAM, Catalog, Inventory, Cart, Shipping, Notification, Analytics = Native. Order, Payment = JVM | Native = ~50ms startup, ~30MB RAM. JVM = debug facil em saga complexa |
| Caddy em vez de Kong | Caddy 2.9 com forward_auth → IAM /auth/validate | ~20MB RAM, HTTPS automatico (Let's Encrypt), Caddyfile declarativo |
| Cloudinary em vez de Media Service | Upload Widget Angular + signed params via IAM | Free tier: 25GB storage, CDN global, resize URL-based |
| Sem modulo common | Cada servico autocontido com codigo duplicado intencionalmente | Evita acoplamento entre servicos |
| SecurityHeaderFilter | ContainerRequestFilter valida X-User-Id/X-User-Role do Caddy | Servicos nunca chamam IAM em runtime |
| Refresh token rotation | Token families: reuso revoga familia inteira | Deteccao de token theft |
| Pessimistic lock no estoque | SELECT ... FOR UPDATE SKIP LOCKED | Previne concorrencia na ultima unidade |
| Webhook 5 camadas | IP restriction + rate limit + HMAC + timestamp + idempotencia | Defense-in-depth |
| Oracle Cloud Free Tier | Ampere A1 ARM (4 OCPU, 24GB RAM) | $0/mes |

## Servicos

| Servico | Porta | Deploy | Descricao |
|---|---|---|---|
| IAM | 8081 | Native | Autenticacao JWT RS256, LGPD, audit log |
| Catalog | 8082 | Native | Produtos, categorias, Cloudinary, busca |
| Inventory | 8083 | Native | Estoque, pessimistic lock, Kafka |
| Cart | 8084 | Native | Carrinho guest/auth, HMAC, merge |
| Order | 8085 | JVM | State machine saga, Kafka consumers |
| Payment | 8086 | JVM | Asaas, webhook 5 camadas |
| Shipping | 8087 | Native | Melhor Envio, circuit breaker |
| Notification | 8088 | Native | Qute templates, email |
| Analytics | 8090 | Native | Dashboards, materialized views |

## Pre-requisitos

- Java 21+ (JAVA_HOME configurado)
- Maven 3.9+ (ou ./mvnw)
- Docker Desktop + Docker Compose
- Node.js 22+ (Angular)
- gh CLI 2.x

## Configuracao

### 1. Clone
`git clone git@github.com:Ivictors/vm-griffes.git`
`cd vm-griffes`

### 2. Configure
`cp .env.example .env`
Edite .env com suas credenciais (JWT, Cloudinary, Asaas, etc)

### 3. Suba infra
`docker compose up -d`

### 4. Dev mode
`cd iam && mvn quarkus:dev`
`cd catalog && mvn quarkus:dev`
(repetir para cada servico)

### 5. Frontend
`cd frontend`
`npm install`
`ng serve`

### 6. Testes
`mvn test` (todos)
`mvn test -pl iam` (servico especifico)

## Estrutura

```
vm-griffes/
  pom.xml              (Parent POM Quarkus BOM)
  .github/workflows/   (CI/CD)
  docker-compose.yml   (PG, Kafka, Caddy, Zipkin)
  caddy/Caddyfile      (API Gateway config)
  iam/                 (Native - Autenticacao 8081)
  catalog/             (Native - Catalogo 8082)
  inventory/           (Native - Estoque 8083)
  cart/                (Native - Carrinho 8084)
  order/               (JVM - Pedidos 8085)
  payment/             (JVM - Pagamentos 8086)
  shipping/            (Native - Frete 8087)
  notification/        (Native - Notificacoes 8088)
  analytics/           (Native - Analytics 8090)
  frontend/            (Angular 19)
  infra/               (Scripts deploy)
```
