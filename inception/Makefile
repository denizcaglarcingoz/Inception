COMPOSE := docker-compose -f srcs/docker-compose.yml

.PHONY: all up down clean fclean re hosts dirs

all: hosts up


dirs:
	mkdir -p /home/$(USER)/data/mariadb /home/$(USER)/data/wordpress

up: dirs
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean: clean
	docker system prune -af --volumes

re: fclean up

# Optional: add login.42.fr -> local IP (required by subject, do once)
hosts:
	@ip=$$(hostname -I | awk '{print $$1}'); \
	if ! grep -q "dcingoz.42.fr" /etc/hosts; then \
		echo "$$ip dcingoz.42.fr" | sudo tee -a /etc/hosts >/dev/null; \
		echo "Added $$ip dcingoz.42.fr"; \
	else echo "hosts entry already present"; fi
