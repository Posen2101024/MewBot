#!make
SHELL     := /bin/bash

COMMIT    ?= $(shell git describe --always)
USERNAME  ?= $(shell whoami)
REGISTRY  ?= $(USERNAME)
NAMESPACE ?= $(shell echo $(shell basename $(PWD)) | tr '[A-Z]' '[a-z]')

IMAGE     := $(REGISTRY)/$(NAMESPACE):$(COMMIT)
PREFIX    := $(USERNAME)_$(NAMESPACE)_$(COMMIT)
SUFFIX    := $(shell LC_CTYPE=C tr -dc 'a-z0-9' </dev/urandom | head -c8)
CONTAINER := $(PREFIX)$(SUFFIX)

kill:
	@set -euo pipefail; \
	CONTAINER_ID=$$(docker ps -q -a -f "name=$(PREFIX)*"); \
	if [[ -n $$CONTAINER_ID ]]; then \
		docker stop $$CONTAINER_ID; \
		docker rm $$CONTAINER_ID; \
	fi;

clean: kill
	@set -euo pipefail; \
	IMAGE_ID=$$(docker images -q "$(IMAGE)"); \
	if [[ -n $$IMAGE_ID ]]; then \
		docker rmi -f $(IMAGE); \
	fi;

build: clean
	docker build --no-cache -t $(IMAGE) .

build-dev: kill
	docker build -t $(IMAGE) .

run:
	docker run -itd \
		-v $(PWD)/redis:/var/lib/redis \
		--name $(CONTAINER) $(IMAGE)
	-docker exec -it $(CONTAINER) /bin/bash

exec:
	@set -euo pipefail; \
	CONTAINER_ID=$$(docker ps -q -a -f "name=$(PREFIX)*" | head -n 1); \
	if [[ -n $$CONTAINER_ID ]]; then \
		docker exec -it $$CONTAINER_ID /bin/bash; \
	fi;

up: build run

dev: build-dev run

push: build
	@echo "Try to push $(IMAGE) to $(REGISTRY)"
	docker push $(IMAGE)
