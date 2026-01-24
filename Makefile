all: up

# Build and start all services
up:
	@echo "Creating volume directories..."
	@mkdir -p /home/isel-mou/data/wordpress
	@mkdir -p /home/isel-mou/data/mariadb
	@echo "Building and starting Docker services..."
	@cd srcs && docker-compose up -d --build
	@echo "✓ Services are up and running"

# Build images without starting containers
build:
	@echo "Building Docker images..."
	@cd srcs && docker-compose build
	@echo "✓ Images built successfully"

# Stop all containers
down:
	@echo "Stopping all containers..."
	@cd srcs && docker-compose down
	@echo "✓ Services stopped and removed"

stop:
	@echo "Stopping containers..."
	@cd srcs && docker-compose stop
	@echo "✓ Services stopped"

start:
	@echo "Starting containers..."
	@cd srcs && docker-compose start
	@echo "✓ Services started"

restart: down up
	@echo "✓ Services restarted"

logs:
	@cd srcs && docker-compose logs -f

# Remove containers
clean: down

# Remove containers, images, and volumes
fclean: clean
	@echo "Cleaning up all resources (images, volumes, data)..."
	@cd srcs && docker-compose down --rmi all -v
	@echo "✓ Full cleanup completed"

# Rebuild everything from scratch
re: fclean up
	@echo "✓ Project rebuilt"

help:
	@echo "Available targets:"
	@echo "  make up       - Build and start all services"
	@echo "  make build    - Build Docker images only"
	@echo "  make down     - Stop and remove containers"
	@echo "  make stop     - Stop containers"
	@echo "  make start    - Start stopped containers"
	@echo "  make restart  - Restart all containers"
	@echo "  make logs     - View service logs"
	@echo "  make clean    - Stop and remove containers"
	@echo "  make fclean   - Stop and remove containers, images, and volumes"
	@echo "  make re       - Rebuild from scratch"

.PHONY: all build up down stop start restart logs clean fclean re