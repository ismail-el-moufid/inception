all: up

MANDATORY_SERVICES = nginx mariadb wordpress redis
BONUS_SERVICES = ftp

# Build and start all containers
up: build
	@echo "Creating volume directories..."
	@mkdir -p /home/isel-mou/data/mariadb
	@mkdir -p /home/isel-mou/data/wordpress
	@sudo chown -R 1000:1000 /home/isel-mou/data/wordpress
	@echo "starting Docker services..."
	@cd srcs && docker compose up -d $(MANDATORY_SERVICES)
	@echo "✓ Services are up and running"

# Build images without starting containers
build:
	@echo "Building Docker images..."
	@cd srcs && docker compose build --parallel $(MANDATORY_SERVICES)
	@echo "✓ Images built successfully"

# Stop and remove containers
down:
	@echo "Stopping all containers..."
	@cd srcs && docker compose down
	@echo "✓ Services stopped and removed"

stop:
	@echo "Stopping containers..."
	@cd srcs && docker compose stop
	@echo "✓ Services stopped"

start:
	@echo "Starting containers..."
	@cd srcs && docker compose start
	@echo "✓ Services started"

restart: down up
	@echo "✓ Services restarted"

logs:
	@cd srcs && docker compose logs -f

clean: down

# Remove containers, images, and volumes
fclean:
	@echo "Cleaning up all resources (images, volumes, data)..."
	@cd srcs && docker compose down --rmi all -v
	@echo "✓ Full cleanup completed"

# Rebuild everything from scratch
re: fclean up
	@echo "✓ Project rebuilt"

build_bonus:
	@echo "Building bonus service images..."
	@cd srcs && docker compose build $(MANDATORY_SERVICES) $(BONUS_SERVICES)
	@echo "✓ Bonus images built successfully"

bonus: build_bonus
	@echo "Creating volume directories..."
	@mkdir -p /home/isel-mou/data/mariadb
	@mkdir -p /home/isel-mou/data/wordpress
	@echo "Starting bonus services..."
	@cd srcs && docker compose up -d $(MANDATORY_SERVICES) $(BONUS_SERVICES)
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

.PHONY: all build up down stop start restart logs clean fclean re bonus help