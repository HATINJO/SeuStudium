# ==========================================
# Estágio 1: Build com ambiente Flutter pré-instalado
# ==========================================
FROM ghcr.io/cirrusci/flutter:stable AS build-stage

USER root
WORKDIR /app

# Copia os arquivos do seu projeto
COPY . .

# Baixa as dependências do Dart/Flutter e compila a Web
RUN flutter pub get
RUN flutter build web --release

# ==========================================
# Estágio 2: Servidor Web de Produção (NGINX)
# ==========================================
FROM nginx:alpine AS production-stage

COPY --from=build-stage /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
