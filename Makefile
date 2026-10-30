NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml

all:
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
