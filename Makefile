NAME := mailserver
TAG := latest
IMAGE_NAME := panubo/$(NAME)

.PHONY: help bash run build push clean

help:
	@printf "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)\n"

bash:  ## Run bash shell
	docker run --rm -it -e MAILNAME=mail.example.com -e MYDOMAIN=example.com -e DB_MAIL_HOST=foo -e DB_SQLGREY_HOST=foo -e GENERATE_TLS=true $(IMAGE_NAME):$(TAG) bash

run:  ## Run server
	docker run -d --name mariadb -e MYSQL_ROOT_PASSWORD='root' mariadb:10.0
	docker run -d --name mailserver --link mariadb:mariadb -e MAILNAME=mail.example.com -e MYDOMAIN=example.com -e GENERATE_TLS=true $(IMAGE_NAME):$(TAG)
	@docker logs -f mailserver
	@docker rm -f mariadb mailserver

build: ## Builds docker image latest
	docker build --pull -t $(IMAGE_NAME):$(TAG) .

push: ## Pushes the docker image to hub.docker.com
	docker push $(IMAGE_NAME):$(TAG)

clean: ## Remove built images
	docker rmi $(IMAGE_NAME):$(TAG) || true
