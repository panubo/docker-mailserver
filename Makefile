docker_tag 	= mailserver

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    APP_HOST := localhost
endif
ifeq ($(UNAME_S),Darwin)
    APP_HOST := $(shell docker-machine ip default)
endif

build:
	docker build -t $(docker_tag) .

bash:
	docker run --rm -it -e MAILNAME=mail.example.com -e MYDOMAIN=example.com -e DB_MAIL_HOST=foo -e DB_SQLGREY_HOST=foo -e GENERATE_TLS=true $(docker_tag) bash

run:
	docker run -d --name mariadb -e MYSQL_ROOT_PASSWORD='root' mariadb:10.0
	$(eval ID := $(shell docker run -d --name mailserver --link mariadb:mariadb -e MAILNAME=mail.example.com -e MYDOMAIN=example.com -e GENERATE_TLS=true ${docker_tag}))
	$(eval IP := $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${ID}))
	@echo "Running ${ID} @ ${IP}"
	@docker logs -f ${ID}
	@docker rm -f mariadb mailserver
