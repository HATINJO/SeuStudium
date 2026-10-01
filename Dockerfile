# Etapa 1: Build
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

WORKDIR /app

COPY . .

RUN flutter pub get
RUN flutter build web --release

# Etapa 2: Nginx
FROM nginx:alpine

COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80
