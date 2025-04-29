
 `docker-compose` file used ONLY for hobby deployments.

### Please take a look at https://posthog.com/docs/self-host/deploy/hobby
# for more info.
#
### PostHog has sunset support for self-hosted K8s deployments.
See: https://posthog.com/blog/sunsetting-helm-support-posthog

#### docker-compose.yml
services:
    db:
        extends:
            file: docker-compose.base.yml
            service: db
        # Pin to postgres 12 until we have a process for pg_upgrade to postgres 15 for exsisting installations
        image: ${DOCKER_REGISTRY_PREFIX:-}postgres:12-alpine
        volumes:
            - postgres-data:/var/lib/postgresql/data

    redis:
        extends:
            file: docker-compose.base.yml
            service: redis
    clickhouse:
        #
        # Note: please keep the default version in sync across
        #       `posthog` and the `charts-clickhouse` repos
        #
        extends:
            file: docker-compose.base.yml
            service: clickhouse
        restart: on-failure
        depends_on:
            - kafka
            - zookeeper
        volumes:
            - ./posthog/posthog/idl:/idl
            - ./posthog/docker/clickhouse/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d
            - ./posthog/docker/clickhouse/config.xml:/etc/clickhouse-server/config.xml
            - ./posthog/docker/clickhouse/users.xml:/etc/clickhouse-server/users.xml
            - clickhouse-data:/var/lib/clickhouse
    zookeeper:
        extends:
            file: docker-compose.base.yml
            service: zookeeper
        volumes:
            - zookeeper-datalog:/datalog
            - zookeeper-data:/data
            - zookeeper-logs:/logs
    kafka:
        extends:
            file: docker-compose.base.yml
            service: kafka
        depends_on:
            - zookeeper

    worker:
        extends:
            file: docker-compose.base.yml
            service: worker
        environment:
            SENTRY_DSN: 'https://public@sentry.example.com/1'
            SITE_URL: https://ph.test.local
            SECRET_KEY: a5d12292df132a417c96a4a8e1178464f271827c512f905af8d39263
        image: posthog/posthog:latest
    web:
        extends:
            file: docker-compose.base.yml
            service: web
        command: /compose/start
        volumes:
            - ./compose:/compose
        image: posthog/posthog:latest
        environment:
            SENTRY_DSN: 'https://public@sentry.example.com/1'
            SITE_URL: https://ph.test.local
            SECRET_KEY: a5d12292df132a417c96a4a8e1178464f271827c512f905af8d39263
            RECORDINGS_INGESTER_URL: http://plugins:6738
        depends_on:
            - db
            - redis
            - clickhouse
            - kafka
            - object_storage

    plugins:
        extends:
            file: docker-compose.base.yml
            service: plugins
        image: posthog/posthog:latest
        environment:
            SENTRY_DSN: 'https://public@sentry.example.com/1'
            SITE_URL: https://ph.test.local
            SECRET_KEY: a5d12292df132a417c96a4a8e1178464f271827c512f905af8d39263
        depends_on:
            - db
            - redis
            - clickhouse
            - kafka
            - object_storage

    caddy:
        image: caddy:2.6.1
        restart: unless-stopped
        ports:
            - '80:80'
            - '443:443'
        volumes:
            - ./Caddyfile:/etc/caddy/Caddyfile
        depends_on:
            - web
    object_storage:
        extends:
            file: docker-compose.base.yml
            service: object_storage
        restart: on-failure
        volumes:
            - object_storage:/data

    asyncmigrationscheck:
        extends:
            file: docker-compose.base.yml
            service: asyncmigrationscheck
        image: posthog/posthog:latest
        environment:
            SENTRY_DSN: 'https://public@sentry.example.com/1'
            SITE_URL: https://ph.test.local
            SECRET_KEY: a5d12292df132a417c96a4a8e1178464f271827c512f905af8d39263
            SKIP_ASYNC_MIGRATIONS_SETUP: 0

    # Temporal containers
    temporal:
        extends:
            file: docker-compose.base.yml
            service: temporal
        environment:
            - ENABLE_ES=false
        ports:
            - 7233:7233
        volumes:
            - ./posthog/docker/temporal/dynamicconfig:/etc/temporal/config/dynamicconfig
    temporal-admin-tools:
        extends:
            file: docker-compose.base.yml
            service: temporal-admin-tools
        depends_on:
            - temporal
    temporal-ui:
        extends:
            file: docker-compose.base.yml
            service: temporal-ui
        ports:
            - 8081:8080
        depends_on:
            temporal:
                condition: service_started
            db:
                condition: service_healthy
    temporal-django-worker:
        command: /compose/temporal-django-worker
        extends:
            file: docker-compose.base.yml
            service: temporal-django-worker
        volumes:
            - ./compose:/compose
        image: posthog/posthog:latest
        environment:
            SENTRY_DSN: 'https://public@sentry.example.com/1'
            SITE_URL: https://ph.test.local
            SECRET_KEY: 2484c9b8a4cec09d8a28302a90249c6ae19401f1e3433325ce532e6c7bfbac84
            DATABASE_URL: postgres://db:5432/posthog
            REDIS_URL: redis://redis/
        depends_on:
            - db
            - redis
            - clickhouse
            - kafka
            - object_storage
            - temporal

volumes:
    zookeeper-data:
    zookeeper-datalog:
    zookeeper-logs:
    object_storage:
    postgres-data:
    clickhouse-data:
