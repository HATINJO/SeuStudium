# ==========================================
# Estágio 1: Build da aplicação Flutter Web
# ==========================================
FROM debian:bookworm-slim AS build-stage

# Instala dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Baixa o SDK do Flutter (versão estável)
RUN git clone https://github.com/flutter/flutter.git -b stable /sdks/flutter
ENV PATH="/sdks/flutter/bin:${PATH}"

# Configura o Flutter estritamente para Web (evita baixar Gradle e Android SDK)
RUN flutter config --no-analytics && \
    flutter config --enable-web && \
    flutter precache --web

WORKDIR /app

# Copia os arquivos e gera a build de produção
COPY . .
RUN flutter pub get
RUN flutter build web --release

# ==========================================
# Estágio 2: Servidor Web de Produção (NGINX)
# ==========================================
FROM nginx:alpine AS production-stage

# Copia os arquivos gerados pelo Flutter para a pasta do NGINX
COPY --from=build-stage /app/build/web /usr/share/nginx/html

# Copia as regras de redirecionamento do NGINX
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
