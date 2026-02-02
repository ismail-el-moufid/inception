_This project was created as part of the 42 curriculum by isel‑mou._

# Inception — Dockerized WordPress Stack

## Overview

This project provides a minimal, production‑oriented Docker Compose stack for hosting a WordPress site. It includes:

- **Nginx**: Acts as the single public entry point with TLS v1.2/v1.3 on port 443.
- **WordPress**: Runs with PHP-FPM in a separate container.
- **MariaDB**: Database container for WordPress.
- **Redis**: object caching for WordPress.
- **FTP**: Local file management of WordPress files.
- **Adminer**: Web-based database management tool.
- **Dozzle**: Web UI for viewing container logs (optional bonus service).
- **Static Docs Site**: Served via nginx.
- **Persistent Data**: Stored on the host under a configurable `DATA_DIR`.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed.
- [Docker Compose](https://docs.docker.com/compose/install/) installed.
- Populate environment variables in `srcs/.env` before building.

## Quick Start

1. **Configure Environment Variables**  
   Create and populate the `.env` file in the `srcs/` directory. See the example below.

```sh
# Data Directory
DATA_DIR=/existing/path/where/data/will/be/stored

# Domain Name
DOMAIN_NAME=localhost

# Database Root Password
DB_ROOT_PASSWORD=your_secure_DB_ROOT_PASSWORD

# WordPress Admin
WP_ADMIN_USER=a_d_m_i_n
WP_ADMIN_PASSWORD=strong_admin_pass
WP_ADMIN_EMAIL=admin@example.com

# WordPress User
WP_NON_ADMIN_USER=author_user
WP_NON_ADMIN_PASSWORD=strong_user_pass

# WordPress Site Settings
WP_SITE_TITLE=Inception

# Database Configuration
WP_DB_NAME=wordpress
WP_DB_USER=wordpress
WP_DB_PASSWORD=your_secure_password

# FTP Configuration
FTP_USER=ftp_user
FTP_PASSWORD=strong_ftp_pass

# WordPress Security Keys
WP_AUTH_KEY=your_auth_key
WP_SECURE_AUTH_KEY=your_secure_auth_key
WP_LOGGED_IN_KEY=your_logged_in_key
WP_NONCE_KEY=your_nonce_key
WP_AUTH_SALT=your_auth_salt
WP_SECURE_AUTH_SALT=your_secure_auth_salt
WP_LOGGED_IN_SALT=your_logged_in_salt
WP_NONCE_SALT=your_nonce_salt
```

2. **Build and Start the Stack**  
   From the repository root, run:

   ```sh
   make
   ```

3. **Stop the Stack**  
   To stop and remove the stack, run:

   ```sh
   make down
   ```

4. **Access the Site**  
   - Website: [https://localhost](https://localhost)
   - Admin Dashboard: [https://localhost/wp-admin](https://localhost/wp-admin)

## Additional Services (bonus)

- Redis (cache)
  - Purpose: object caching for WordPress (configured via REDIS_HOST/REDIS_PORT in srcs/.env).
  - How to start: included by default in the normal stack.
- Adminer (DB management)
  - Access: proxied via nginx at https://`DOMAIN_NAME`/adminer.php
  - Dockerfile: [srcs/requirements/bonus/adminer/Dockerfile](srcs/requirements/bonus/adminer/Dockerfile)
  - How to start: included by default in the normal stack.
- Docs website (static)
  - Access: proxied by nginx at https://`DOMAIN_NAME`/Docs
  - Content source: [srcs/requirements/bonus/docs](srcs/requirements/bonus/docs)
  - How to start: included by default in the normal stack.

- Note: Dozzle (logs UI) and FTP are extra bonus services and are not started by the default `make`. Run `make bonus` to build and start them.
- Dozzle (container logs UI)
  - Access: bound to localhost only — [http://127.0.0.1:8081](http://127.0.0.1:8081)
  - Note: Dozzle requires running `make bonus` to build and start it.
- FTP (optional)
  - Access: 127.0.0.1:21 (passive port 10000). Intended for bonus usage and points; enable only if needed.
  - Note: FTP is a bonus service and requires running `make bonus` to build and start it.

## Resources

- [Docker](https://docs.docker.com)
- [Docker Compose](https://docs.docker.com/compose/)
- WordPress + PHP-FPM documentation
- How AI was used: generated templates for README/USER_DOC/DEV_DOC and a starter static site; AI was also used to research best practices for configuring the different services; all generated content was reviewed and adapted manually.

## Project Description & Design Choices

- **Use of Docker**: Lightweight containers for each service, reproducible builds via Dockerfiles and Docker Compose.
- **Main Choices**:
  - Base images: Alpine (penultimate stable version).

### Short Comparisons

- **Virtual Machines vs Docker**
  - VMs: Full OS per instance, heavier. Docker: Lightweight containers sharing kernel, faster start and smaller footprint.
- **Secrets vs Environment Variables**
  - .env: Convenient but visible to processes and to anyone with access to files. Secrets: More secure (Docker secrets or mounted files with restricted permissions).
- **Docker Network vs Host Network**
  - Docker network isolates containers by default and allows controlled connectivity. Host network exposes container directly to host network namespace (not allowed here).
- **Docker Volumes vs Bind Mounts**
  - Volumes: Managed by Docker, portable and recommended for persistent app data. Bind mounts map host directories (useful for development, but less portable).
