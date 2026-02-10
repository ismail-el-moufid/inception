all: up

MANDATORY_SERVICES = nginx mariadb wordpress redis docs adminer
BONUS_SERVICES = ftp dozzle

UID = $(shell id -u)
GID = $(shell id -g)

# Prevent running services as root
ifeq ($(UID),0)
	UID = 1000
	GID = 1000
endif

DOCKER_COMPOSE = HOST_UID=${UID} HOST_GID=${GID} docker compose

-include srcs/.env

# Build and start all containers
up: build
	@echo "Creating volume directories..."
	@mkdir -p "$(DATA_DIR)/mariadb"
	@mkdir -p "$(DATA_DIR)/wordpress"
	@echo "starting Docker services..."
	@cd srcs && ${DOCKER_COMPOSE} up -d $(MANDATORY_SERVICES)
	@echo "✓ Services are up and running"

# Build images without starting containers
build:
	@echo "Building Docker images..."
	@cp README.md srcs/requirements/bonus/docs/index.md
	@cd srcs && ${DOCKER_COMPOSE} build --parallel $(MANDATORY_SERVICES)
	@echo "✓ Images built successfully"

# Stop and remove containers
down:
	@echo "Stopping and removing all containers..."
	@cd srcs && ${DOCKER_COMPOSE} down
	@echo "✓ Services stopped and removed"

stop:
	@echo "Stopping containers..."
	@cd srcs && ${DOCKER_COMPOSE} stop
	@echo "✓ Services stopped"

start:
	@echo "Starting containers..."
	@cd srcs && ${DOCKER_COMPOSE} start
	@echo "✓ Services started"

# Stop, remove and restart all containers
restart: down up
	@echo "✓ Services restarted"

logs:
	@cd srcs && ${DOCKER_COMPOSE} logs -f

clean: down

# Remove containers, images, and volumes
fclean:
	@echo "Cleaning up all resources (containers, images, volumes)..."
	@cd srcs && ${DOCKER_COMPOSE} down --rmi all -v
	@echo "✓ Full cleanup completed"

# Rebuild everything from scratch
re: fclean up
	@echo "✓ Project rebuilt"

build_bonus:
	@echo "Building bonus service images..."
	@cp README.md srcs/requirements/bonus/docs/index.md
	@cd srcs && ${DOCKER_COMPOSE} build --parallel $(MANDATORY_SERVICES) $(BONUS_SERVICES)
	@echo "✓ Bonus images built successfully"

bonus: build_bonus
	@echo "Creating volume directories..."
	@mkdir -p "$(DATA_DIR)/mariadb"
	@mkdir -p "$(DATA_DIR)/wordpress"
	@echo "Starting bonus services..."
	@cd srcs && ${DOCKER_COMPOSE} up -d $(MANDATORY_SERVICES) $(BONUS_SERVICES)
	@echo "✓ Bonus services are up and running"

help:
	@echo "Available targets:"
	@echo "  make up       - Build and start all services"
	@echo "  make build    - Build Docker images only"
	@echo "  make down     - Stop and remove containers"
	@echo "  make stop     - Stop containers"
	@echo "  make start    - Start stopped containers"
	@echo "  make restart  - Stop, remove and restart all services"
	@echo "  make logs     - View service logs"
	@echo "  make clean    - Stop and remove containers"
	@echo "  make fclean   - Stop and remove containers, images, and volumes"
	@echo "  make re       - Rebuild from scratch"
	@echo "  make bonus    - Start bonus services"

.PHONY: all build up down stop start restart logs clean fclean re build_bonus bonus help