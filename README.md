*This project has been created as part of the 42 curriculum by mamaimai.*

# Inception

## Description

The Inception project is a system administration project that aims to introduce the use of Docker and Docker Compose to create and manage a small infrastructure made up of multiple services.

The goal of this project is to build a secure and functional WordPress website using separate Docker containers for each service. The infrastructure consists of three main services:

- **NGINX:** Acts as the web server and provides secure access to the website through HTTPS using TLS.
- **WordPress:** Runs the WordPress website using PHP-FPM.
- **MariaDB:** Stores the WordPress database and its information.

Each service runs in its own Docker container and communicates with the other services through a dedicated Docker network.

The project also uses two persistent Docker named volumes: one to store the WordPress database and another to store the WordPress website files. This ensures that data is preserved even when containers are stopped, removed or restarted.

The entire infrastructure is managed using Docker Compose, with a Makefile to simplify the main commands used to build, start, stop and manage the project.

## Instructions

### 1. Prerequisites

Before running the project, make sure the following tools are installed on the host machine:

- **Docker:** Used to build and run containers.
- **Docker Compose:** Used to manage the multi-container infrastructure.
- **GNU Make:** Used to execute the commands defined in the Makefile.
- **Git:** Used to clone and manage the project repository.

The project was developed on Debian 13 (Trixie) using Oracle VirtualBox and the GNOME desktop environment.

### 2. Installation

Clone the project repository:

```bash
git clone <repository-url>
cd inception
```

Make sure Docker, Docker Compose and Make are installed and available on your machine.

### 3. Environment Configuration

Before starting the project, create an environment configuration file named `.env` inside the `srcs/` directory:

```bash
nano srcs/.env
```

This file contains the environment variables required by MariaDB and WordPress to configure the database and establish the connection between both services.

Add the following variables:

```bash
# ===== MariaDB Configuration =====
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress_user
MYSQL_PASSWORD=your_database_password
MYSQL_ROOT_PASSWORD=your_root_password
```

**Environment Variables Description:**

- `MYSQL_DATABASE`: Name of the database created by MariaDB.
- `MYSQL_USER`: Username of the MariaDB user (non-root).
- `MYSQL_PASSWORD`: Password assigned to the MariaDB user.
- `MYSQL_ROOT_PASSWORD`: Password for the MariaDB root account.

**How it works:**

- MariaDB uses these variables to initialize the database and configure its users.
- WordPress uses `MYSQL_DATABASE`, `MYSQL_USER` and `MYSQL_PASSWORD` to establish its database connection.
- Docker Compose makes the `.env` variables available to both MariaDB and WordPress through the `env_file` directive.

**Important:**

- Replace the example values with your own credentials.
- Make sure the variable names match those referenced in the Docker Compose file and service initialization scripts.
- The `.env` file is excluded from Git and must not be committed to the repository.
- Keep your passwords private and restrict access to this file.

### 4. Domain Configuration

To access the WordPress website using your personal 42 domain name, configure the local hostname resolution inside your virtual machine.

Open the `/etc/hosts` file:

```bash
sudo nano /etc/hosts
```

Add the following entry:

```text
10.0.2.15 mamaimai.42.fr
```

Replace `mamaimai` with your own 42 login and make sure the IP address corresponds to your virtual machine's network configuration.

In this project, `10.0.2.15` is the IP address used by the Debian virtual machine in the VirtualBox development environment.

This configuration allows your virtual machine to resolve `mamaimai.42.fr` to its own IP address, making the WordPress website accessible through:

```text
https://mamaimai.42.fr
```

Since NGINX uses HTTPS with a self-signed TLS certificate, your browser may display a security warning when accessing the website. This is expected in the development environment.

### 5. Compilation and Execution

To build the Docker images and start all services, run:

```bash
make
```

This command:

- Creates the required data directories under `/home/mamaimai/data/`.
- Builds the Docker images.
- Creates and starts the containers using Docker Compose.

The infrastructure consists of three services:

- NGINX
- WordPress
- MariaDB

### 6. Useful Makefile Commands

The Makefile provides several commands to simplify project management:

| Command | Description |
|---|---|
| `make` | Creates data directories, builds images and starts the infrastructure. |
| `make build` | Builds Docker images. |
| `make up` | Starts the containers. |
| `make down` | Stops and removes containers. |
| `make start` | Starts stopped containers. |
| `make stop` | Stops running containers. |
| `make logs` | Displays container logs. |
| `make re` | Rebuilds and restarts the infrastructure. |
| `make clean` | Stops and removes containers. |
| `make fclean` | Removes containers, images and named volumes. |

**Warning:** `make fclean` removes Docker named volumes and their persistent data. Use it carefully because database and website data may be permanently deleted.

### 7. Accessing the Website

Once all containers are running, open your browser and visit:

```text
https://mamaimai.42.fr
```

The project uses a self-signed TLS certificate. Therefore, your browser may display a security warning when accessing the website. This is expected in the development environment.

### 8. Checking the Infrastructure

To check whether the containers are running:

```bash
sudo docker compose -f srcs/docker-compose.yml ps
```

To display the Docker volumes:

```bash
sudo docker volume ls
```

To inspect a volume:

```bash
sudo docker volume inspect <volume_name>
```

To check the project logs:

```bash
make logs
```

To validate the Docker Compose configuration:

```bash
sudo docker compose -f srcs/docker-compose.yml config -q
```

These commands help verify that the services are running correctly and that the persistent volumes have been created.

## Resources

The following resources were useful during the development of this project.

### Official Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Volumes](https://docs.docker.com/engine/storage/volumes/)
- [Docker Networking](https://docs.docker.com/engine/network/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Documentation](https://mariadb.com/docs/)
- [Debian Documentation](https://www.debian.org/doc/)

### Additional Learning Resources

- [Docker Introduction](https://www.youtube.com/watch?v=4XVfmGE1F_w)
- [Docker and Containers](https://www.youtube.com/watch?v=ZeYIp1PrWXc)
- [Docker Compose Tutorial](https://www.youtube.com/watch?v=cu3_ldKZ0os)
- [Docker Networking](https://www.youtube.com/watch?v=JU5vvLNipXY)

### AI Usage

AI tools, including ChatGPT, were used as learning and assistance resources during the development of this project.

They were used for:

- Understanding Docker, Docker Compose, containers, networks and volumes.
- Explaining configuration files, Dockerfiles and shell scripts.
- Troubleshooting configuration and service-related issues.
- Understanding commands and verifying the behavior of the infrastructure.
- Improving project documentation, including the README, USER_DOC and DEV_DOC.

All configurations and commands were reviewed and tested in the virtual machine. AI was used as a support tool to improve understanding and assist with development.

## Project Structure

The project directory is organised as follows:

```text
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
    ├── .env                  # Created locally, not committed to Git
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        │       └── setup-wordpress.sh
        └── mariadb/
            ├── Dockerfile
            └── tools/
                └── init-db.sh
```

## Project Description and Technical Choices

### 1. Docker and Project Architecture

Docker is used to create isolated environments for each service. Docker Compose manages the complete infrastructure and allows the services to be built and started together.

The project consists of three main services:

- **NGINX:** Acts as the web server and entry point. It handles HTTPS connections using TLS and forwards PHP requests to WordPress through PHP-FPM.
- **WordPress:** Provides the website and communicates with MariaDB to store and retrieve website information.
- **MariaDB:** Stores the WordPress database, including posts, pages, users and comments.

The services communicate through a dedicated Docker bridge network. Persistent data is stored using two Docker named volumes.

### 2. Sources Included in the Project

The project contains the following configuration files and scripts:

- `srcs/docker-compose.yml`: Defines services, networks, volumes, ports and environment configuration.
- `srcs/requirements/nginx/Dockerfile`: Builds the NGINX image.
- `srcs/requirements/nginx/conf/nginx.conf`: Configures the web server and HTTPS connections.
- `srcs/requirements/wordpress/Dockerfile`: Builds the WordPress environment and installs PHP-FPM and required components.
- `srcs/requirements/wordpress/tools/setup-wordpress.sh`: Configures and initializes WordPress.
- `srcs/requirements/mariadb/Dockerfile`: Builds the MariaDB image.
- `srcs/requirements/mariadb/tools/init-db.sh`: Initializes the database and its users.
- `srcs/.env`: Contains environment variables and credentials. This file is excluded from Git.
- `Makefile`: Simplifies the commands used to build, start, stop and manage the infrastructure.

### 3. Main Design Choices

#### 3.1 Virtual Machines vs Docker

| Virtual Machines | Docker |
|---|---|
| Each VM runs its own operating system. | Containers share the host operating system kernel. |
| Requires more system resources. | Generally uses fewer resources. |
| Usually takes longer to start. | Containers start quickly. |
| Provides hardware-level virtualization. | Provides process-level isolation. |

**Choice:** Docker was chosen because it provides lightweight and isolated environments for each service without requiring a separate operating system for every application.

#### 3.2 Secrets vs Environment Variables

| Secrets | Environment Variables |
|---|---|
| Designed for handling sensitive information. | Used for application configuration and credentials. |
| Can be provided to services as files. | Passed through the process environment. |
| Can reduce exposure of sensitive values. | May be visible through container inspection. |

**Choice:** Environment variables are used to configure MariaDB and WordPress. They are stored in the `.env` file, which is excluded from Git.

Docker Secrets are an alternative for securely managing sensitive information, especially in production environments, but are not implemented in this project.

#### 3.3 Docker Network vs Host Network

| Docker Network (Bridge) | Host Network |
|---|---|
| Provides an isolated network for containers. | Shares the host's network namespace. |
| Containers communicate using service names. | Containers use the host network directly. |
| Ports must be published to expose services. | Containers share the host's network ports. |
| Provides better network isolation. | Provides less network isolation. |

**Choice:** A dedicated Docker bridge network named `inception` is used. It allows NGINX, WordPress and MariaDB to communicate internally using their service names. Only NGINX exposes a port to the host machine.

#### 3.4 Docker Volumes vs Bind Mounts

| Docker Volumes | Bind Mounts |
|---|---|
| Managed by Docker. | Linked directly to a host directory or file. |
| Docker manages their lifecycle. | The user manages the host paths. |
| Suitable for persistent application data. | Useful for sharing host files with containers. |

**Choice:** Two Docker named volumes are used to store persistent data:

- `wordpress_data`: Stores WordPress website files.
- `mariadb_data`: Stores the MariaDB database.

The volumes are configured with Docker's local driver and driver options to use the following host directories:

```text
/home/mamaimai/data/wordpress
/home/mamaimai/data/mariadb
```

This configuration allows Docker to manage named volumes while directing their storage to the required host directories.

The local driver uses the `bind` option to connect each named volume to its corresponding host directory. This ensures that website files and database data remain available when containers are stopped or recreated.