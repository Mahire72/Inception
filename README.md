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
### Prerequisites
Before running the project, make sure you have installed:
`Docker`: Used to build and run containers.
`Docker Compose`: Used to manage the multi-container infrastructure.
`Make`: Used to execute the commands defined in the Makefile.

The project was developed on Debian 13 (Trixie) using VirtualBox.

### Installation and Configuration
`1. Clone the project repository:`
                git clone <repository-url>
                cd inception
Make sure Docker, Docker Compose and Make are installed and available on your machine.