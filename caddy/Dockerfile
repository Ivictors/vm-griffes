# Stage 1: Compilar Caddy com plugin rate-limit
FROM caddy:2.11-alpine-builder AS builder
RUN xcaddy build \
    --with github.com/mholt/caddy-ratelimit

# Stage 2: Build Angular (usado em staging/prod a partir da Fase 7)
FROM node:21-alpine AS angular
WORKDIR /app
COPY angular/ .
RUN npm ci && npm run build --prod

# Stage 3: Imagem final
FROM caddy:2.11-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY --from=angular /app/dist/vmgriffes/browser /srv/angular
COPY Caddyfile /etc/caddy/Caddyfile
