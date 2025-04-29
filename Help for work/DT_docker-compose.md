sudo nano ~/docker/dt/docker-compose.yml

### Config DT

version: '3.7'

services:
  apiserver:
    container_name: dtrack-apiserver
    image: dependencytrack/apiserver
    depends_on:
      - db
    environment:
      - ALPINE_DATABASE_MODE=external
      - ALPINE_DATABASE_URL=jdbc:postgresql://db:5432/dtrack
    #jdbc:postgresql://db:5432/dtrack
      - ALPINE_DATABASE_DRIVER=org.postgresql.Driver
    #  - ALPINE_DATABASE_DRIVER_PATH=/extlib/postgresql-42.2.5.jar
      - ALPINE_DATABASE_USERNAME=dtrack
      - ALPINE_DATABASE_PASSWORD=DTpg!2604#
    # - ALPINE_DATABASE_POOL_ENABLED=true
    # - ALPINE_DATABASE_POOL_MAX_SIZE=20
    # - ALPINE_DATABASE_POOL_MIN_IDLE=10
    # - ALPINE_DATABASE_POOL_IDLE_TIMEOUT=300000
    # - ALPINE_DATABASE_POOL_MAX_LIFETIME=600000
    #
    # Optional HTTP Proxy Settings
    # - ALPINE_HTTP_PROXY_ADDRESS=proxy.example.com
    # - ALPINE_HTTP_PROXY_PORT=8888
    # - ALPINE_HTTP_PROXY_USERNAME=
    # - ALPINE_HTTP_PROXY_PASSWORD=
    # - ALPINE_NO_PROXY=
    #
    networks:
      - dtrack
    deploy:
      resources:
        limits:
          memory: 12288m
        reservations:
          memory: 8192m
      restart_policy:
        condition: on-failure
    ports:
      - "127.0.0.1:8081:8080"
    volumes:
      - "./data:/data"
    restart: unless-stopped

  frontend:
    container_name: dtrack-frontend
    image: dependencytrack/frontend
    depends_on:
      - apiserver
    environment:
      # The base URL of the API server.
      # NOTE:
      #   * This URL must be reachable by the browsers of your users.
      #   * The frontend container itself does NOT communicate with the API server directly, it just serves static files.
      #   * When deploying to dedicated servers, please use the external IP or domain of the API server.
      - API_BASE_URL=https://dt2.ksb.local:8443
    networks:
      - dtrack
#    volumes:
#      - "dependency-frontend:/data:ro"
#      - "/var/lib/docker/volumes/dtrack_dependency-frontend/_data/default.conf:/etc/nginx/conf.d/default.conf"
    ports:
      - "127.0.0.1:8080:8080"
    restart: unless-stopped

  db:
    container_name: dtrack-db
    image: postgres:16
    restart: unless-stopped
    environment:
      - POSTGRES_USER=dtrack
      - POSTGRES_PASSWORD=DTpg!2604#
      - POSTGRES_DB=dtrack
    networks:
      - dtrack
    volumes:
      - ./postgresql:/var/lib/postgresql
      - ./postgresql_data:/var/lib/postgresql/data

networks:
  dtrack:

#volumes:
#  dependency-frontend: