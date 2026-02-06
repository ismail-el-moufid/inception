# User Documentation

Overview

- This project runs a secure (HTTPS) WordPress site with separate containers for nginx (TLS frontend), WordPress + php-fpm, MariaDB and Redis (cache).

Start and stop the stack

- Configure environment:
  - Edit [srcs/.env](srcs/.env) and set DATA_DIR, DOMAIN_NAME, database and admin credentials.
- Start:
  - From repo root run:

```sh
# From repo root
make
```

- This calls the [`Makefile`](Makefile) and uses [srcs/docker-compose.yml](srcs/docker-compose.yml).
- Stop:

```sh
# Stop the stack
make down

# Remove images and volumes (danger: data loss)
make fclean
```

Accessing the website and admin

- Website URL: [localhost](https://localhost).
- Admin dashboard: [localhost/wp-admin](https://localhost/wp-admin)
  - Use WP_ADMIN_USER and WP_ADMIN_PASSWORD from [srcs/.env](srcs/.env)
  - Note: admin username in this project must not contain "admin" per subject rules.

Bonus services & admin tools

- Note: Redis, Adminer, and the Docs site run by default.
- Note: FTP and Dozzle are extra bonus services and are not started by the default `make`. Run `make bonus` to build and start them.
- Adminer (database web UI)
  - URL: [localhost/adminer.php](https://localhost/adminer.php)
  - Use DB credentials from [srcs/.env](srcs/.env)
- Dozzle (logs viewer)
  - URL: [localhost:8081](http://localhost:8081)
  - Note: Dozzle is bound to localhost for security.
- FTP (optional bonus)
  - Host: localhost Port: 21
  - Credentials: FTP_USER / FTP_PASSWORD from [srcs/.env](srcs/.env)
- Docs site (static)
  - URL: [localhost/Docs](https://localhost/Docs)
- Redis cache
  - Redis is used as WordPress object cache when enabled. Configuration comes from REDIS_HOST/REDIS_PORT in [srcs/.env](srcs/.env).
  - To check redis status: cd srcs && docker compose ps redis && docker compose logs redis

Where credentials and data are stored

- Credentials: stored in [srcs/.env](srcs/.env) (do not commit to git).
- Persistent data:
  - WordPress files and DB files are stored on the host under the DATA_DIR path set in [srcs/.env](srcs/.env).
  - The exact bind locations are configured in [srcs/docker-compose.yml](srcs/docker-compose.yml).

Health checks and verification

- Check running services:

```sh
cd srcs && docker compose ps
```

- Tail logs:

```sh
cd srcs && docker compose logs -f
```

- Confirm WordPress is serving via HTTPS only (nginx binds 443). Try HTTP (port 80) — it should not respond.

Basic troubleshooting

- Can't access site:

```sh
# Verify containers are running
cd srcs && docker compose ps

# Check nginx logs
cd srcs && docker compose logs nginx
```

- Verify DOMAIN_NAME resolves to your VM IP (hosts file or DNS).
- Database errors:

```sh
# Check mariadb logs
cd srcs && docker compose logs mariadb
```

- Verify DB credentials in [srcs/.env](srcs/.env)

Where to find more info

- Project README: [README.md](README.md)
- Compose config: [srcs/docker-compose.yml](srcs/docker-compose.yml)
- Service Dockerfiles and scripts: [srcs/requirements](srcs/requirements)
