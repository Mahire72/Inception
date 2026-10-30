# User Documentation

## 1. Overview

This project provides a WordPress website using three services:

- **NGINX:** Web server that handles HTTPS connections on port 443.
- **WordPress:** Content management system used to manage the website.
- **MariaDB:** Database used to store WordPress data.

## 2. Starting the project

From the root of the repository, run:

```bash
make
```

This builds the Docker images and starts the services in the background.

## 3. Stopping the project

To stop and remove the containers and network without deleting persistent data:

```bash
make down
```

To stop the containers without removing them:

```bash
make stop
```

To start existing stopped containers:

```bash
make start
```

## 4. Accessing the website

Open the following address in your browser:

https://mamaimai.42.fr

The website uses HTTPS with a self-signed certificate. Your browser may display a security warning.

## 5. Accessing the administration panel

Open:

https://mamaimai.42.fr/wp-admin

Log in using the WordPress administrator account created during installation.

## 6. Managing credentials

Database credentials are configured in the `srcs/.env` file.

WordPress administrator credentials are created during the WordPress installation.

Keep all passwords private. Never share or publish the `.env` file.

## 7. Checking the services

To check the status of the containers:

```bash
sudo docker compose -f srcs/docker-compose.yml ps
```

To view service logs:

```bash
sudo docker compose -f srcs/docker-compose.yml logs
```

To check the logs of an individual service:

```bash
sudo docker compose -f srcs/docker-compose.yml logs nginx
sudo docker compose -f srcs/docker-compose.yml logs wordpress
sudo docker compose -f srcs/docker-compose.yml logs mariadb
```
