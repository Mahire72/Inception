# Developer Documentation

## 1. Project Overview

Inception is a Docker-based infrastructure composed of three services:

- **NGINX:** Handles HTTPS connections on port 443 and forwards PHP requests to WordPress.
- **WordPress:** Runs PHP-FPM and provides the website.
- **MariaDB:** Stores the WordPress database.

Each service has its own Dockerfile and configuration files.

## 2. Prerequisites

The following tools are required:

- Linux virtual machine
- Docker Engine
- Docker Compose plugin
- GNU Make
- Git

## 3. Project Structure

```text
inception/
├── Makefile
├── .gitignore
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/setup-wordpress.sh
        └── mariadb/
            ├── Dockerfile
            └── tools/init-db.sh
```

## 4. Environment Configuration

Create the `srcs/.env` file before starting the project.

The required variables are:

- `DOMAIN_NAME`
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MYSQL_ROOT_PASSWORD`

Use your own values for the passwords. Never commit `.env` or share its contents.

## 5. Building and Starting the Project

From the repository root:

```bash
make
```

This builds the Docker images and starts the containers in detached mode.

To build images without starting the containers:

```bash
make build
```

To start existing containers:

```bash
make up
```

## 6. Makefile Commands

| Command | Description |
|---|---|
| `make` | Builds and starts all services |
| `make build` | Builds Docker images |
| `make up` | Starts services in detached mode |
| `make down` | Stops and removes containers and network |
| `make start` | Starts stopped containers |
| `make stop` | Stops running containers |
| `make logs` | Displays service logs |
| `make clean` | Removes containers and network |
| `make fclean` | Removes containers, images and volumes |
| `make re` | Rebuilds and restarts the project |

**Warning:** `make fclean` removes Docker volumes. Persistent database and website data may be lost.

## 7. Docker Compose Commands

The Compose configuration is located at `srcs/docker-compose.yml`.

Check the configuration:

```bash
sudo docker compose -f srcs/docker-compose.yml config
```

Display running services:

```bash
sudo docker compose -f srcs/docker-compose.yml ps
```

Display logs:

```bash
sudo docker compose -f srcs/docker-compose.yml logs
```

Inspect containers:

```bash
sudo docker ps -a
```

## 8. Network Architecture

All three services communicate through a dedicated Docker bridge network.

- NGINX communicates with WordPress on port 9000.
- WordPress communicates with MariaDB on port 3306.
- Only NGINX exposes a port to the host: port 443.

## 9. Data Persistence

The project uses two persistent host directories:

- `/home/mamaimai/data/wordpress`
- `/home/mamaimai/data/mariadb`

These directories store WordPress website files and MariaDB database files.

Removing containers does not normally delete this bind-mounted data.

Removing the Docker containers and volumes does not necessarily delete these host directories. However, manually deleting their contents will destroy the stored data.

## 10. Troubleshooting

Check service status:

```bash
sudo docker compose -f srcs/docker-compose.yml ps
```

Inspect logs for a specific service:

```bash
sudo docker compose -f srcs/docker-compose.yml logs nginx
sudo docker compose -f srcs/docker-compose.yml logs wordpress
sudo docker compose -f srcs/docker-compose.yml logs mariadb
```

Rebuild and restart the project:

```bash
make re
```
