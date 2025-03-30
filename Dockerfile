# Etap 1: Budowanie aplikacji Node.js
FROM scratch AS builder
ADD alpine-minirootfs-3.21.3-x86_64.tar /

WORKDIR /app

# Instalacja Node.js i npm
RUN apk add --no-cache nodejs npm

# Skopiowanie plików aplikacji
COPY package*.json ./

# Instalacja zależności
RUN npm install

COPY server.js ./

# Otworzenie portu aplikacji
EXPOSE 3000

# Etap 2: Nginx jako reverse proxy
FROM nginx:alpine

RUN apk add --no-cache nodejs npm

WORKDIR /app

# Skopiowanie aplikacji z etapu 1 do katalogu serwera Nginx
COPY --from=builder /app ./

# Skopiowanie pliku nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Ustawienie zmiennej środowiskowej VERSION
ARG VERSION
ENV VERSION=$VERSION

# Dodanie healthcheck do monitorowania stanu aplikacji
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl --fail http://localhost:80 || exit 1

# Otworzenie portu 80 (dla Nginx)
EXPOSE 80
# Uruchomienie Node.js i Nginx jednocześnie
CMD sh -c "node /app/server.js & nginx -g 'daemon off;'"