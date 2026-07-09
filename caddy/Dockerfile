# Stage 1: Compilar Caddy com plugin rate-limit
FROM caddy:2.11-builder AS builder
RUN xcaddy build \
    --with github.com/mholt/caddy-ratelimit

# Stage 2: Build Angular
# TODO: Reativar quando o Angular estiver scaffolded (package.json + package-lock.json em angular/)
# FROM node:21-alpine AS angular
# WORKDIR /app
# COPY angular/package.json angular/package-lock.json ./
# RUN npm ci
# COPY angular/ .
# RUN npm run build --configuration production

# Stage 3: Imagem final
FROM caddy:2.11-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
# COPY --from=angular /app/dist/vmgriffes/browser /srv/angular
COPY caddy/Caddyfile /etc/caddy/Caddyfile
