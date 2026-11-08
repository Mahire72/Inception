NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml

DATA_DIR = /home/mamaimai/data

all:
	sudo mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

logs:
	$(COMPOSE) logs

clean:
	$(COMPOSE) down

fclean:
	$(COMPOSE) down --rmi all --volumes

re:
	$(COMPOSE) down
	$(COMPOSE) up -d --build

.PHONY: all build up down start stop logs clean fclean re
