# Inception
This project has been created as part of the 42 curriculum by mamaimai.

## Description
The Inception project is a system administration project that aims to introduce the use of Docker 
and Docker Compose to create and manage a small infrastructure made up of multiple services.

The goal of this project is to build a secure and functional WordPress website using separate 
Docker containers for each service. The infrastructure consists of three main services:

NGINX: Acts as the web server and provides secure access to the website through HTTPS using TLS.

WordPress: Runs the WordPress website using PHP-FPM.

MariaDB: Stores the WordPress database and its information.

Each service runs in its own Docker container and communicates with the other services through a dedicated Docker network.

The project also uses two persistent Docker named volumes: one to store the WordPress database and another to store the WordPress website files. This ensures that data is preserved even when containers are stopped, removed, or restarted.

The entire infrastructure is managed using Docker Compose, with a Makefile to simplify the main commands used to build, start, stop, and manage the project.

## Instructions

### 1. Prerequisites

Before running the project, make sure the following tools are installed on the host machine:

- **Docker:** Used to build and run containers.
- **Docker Compose:** Used to manage the multi-container infrastructure.
- **Make:** Used to execute the commands defined in the Makefile.

The project was developed on Debian 13 (Trixie) using VirtualBox.

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

The file must contain the environment variables required by MariaDB and WordPress.

The required information includes:

- **Domain configuration:** The domain name used to access the WordPress website.
- **MariaDB configuration:** Database name, database username, database password and root password.
- **WordPress configuration:** Administrator username, password and email address, as well as a second WordPress user's username, password and email address.

Replace the example values with your own credentials. The variable names must match those referenced in the Docker Compose file and service configuration scripts.

For security reasons, do not share your passwords or commit the `.env` file to Git.

### 4. Domain Configuration

Configure your domain name so that it points to your local machine.

Add an entry to the host machine's `/etc/hosts` file:

```text
127.0.0.1 login.42.fr
```

Replace `login` with your own login.

The IP address should correspond to your machine's network configuration. For example, in the VirtualBox VM used during development, the address is `10.0.2.15`.

### 5. Compilation and Execution

To build the Docker images and start all services, run:

```bash
make
```

This command:

- Creates the required data directories under `/home/login/data/`.
- Builds the Docker images.
- Creates and starts the containers using Docker Compose.

The infrastructure consists of three services:

- NGINX
- WordPress
- MariaDB

### 6. Useful Makefile Commands

| Command | Description |
|---|---|
| `make` | Creates data directories, builds images and starts the infrastructure |
| `make build` | Builds Docker images |
| `make up` | Starts the containers |
| `make down` | Stops and removes containers |
| `make start` | Starts stopped containers |
| `make stop` | Stops running containers |
| `make logs` | Displays container logs |
| `make re` | Rebuilds and restarts the infrastructure |
| `make clean` | Stops and removes containers |
| `make fclean` | Removes containers, images and named volumes |

**Warning:** `make fclean` removes Docker named volumes and their persistent data. Use it carefully because database and website data may be permanently deleted.

### 7. Accessing the Website

Once all containers are running, open your browser and visit:

```text
https://login.42.fr
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

These commands help verify that the services are running and that the persistent volumes have been created.