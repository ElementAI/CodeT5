###############################################################################
# Configuration

PROJECT_NAME ?= code-t5

USERNAME ?= $(shell whoami 2> /dev/null)
DOCKER_IMAGE_NAME ?= $(USERNAME)-$(PROJECT_NAME)
DOCKER_IMAGE_VERSION ?= $(shell git rev-parse --short=7 HEAD)
DOCKERFILE=Dockerfile

# Remote repository for pushing
TOOLKIT_ACCOUNT ?= $$(eai account get --no-header --fields id)
TOOLKIT_IMAGE_REGISTRY_VOLATILE ?= volatile-registry.console.elementai.com
TOOLKIT_IMAGE_NAME ?= $(TOOLKIT_IMAGE_REGISTRY_VOLATILE)/$(TOOLKIT_ACCOUNT)/$(DOCKER_IMAGE_NAME)
TOOLKIT_IMAGE_TAG ?= $(TOOLKIT_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)

DEV_CONFIG ?= configs/dev.yml
DOCKERFILE_DEV=Dockerfile-dev
TOOLKIT_IMAGE_REGISTRY ?= registry.console.elementai.com
TOOLKIT_IMAGE_NAME_DEV ?= $(TOOLKIT_IMAGE_REGISTRY)/$(TOOLKIT_ACCOUNT)/$(DOCKER_IMAGE_NAME)-dev
TOOLKIT_IMAGE_TAG_DEV ?= $(TOOLKIT_IMAGE_NAME_DEV):latest

EXPERIMENT_DATA ?= 9af28ad3-d46b-49cc-9820-3effe833056d 
###############################################################################
# Toolkit commands

.PHONY: build
build:
	DOCKER_BUILDKIT=1 docker build . --progress plain -f $(DOCKERFILE) \
	-t $(TOOLKIT_IMAGE_TAG)

.PHONY: push
push: build
	docker push $(TOOLKIT_IMAGE_TAG)

.PHONY: submit
submit: push
	IMAGE_NAME=$(TOOLKIT_IMAGE_TAG) \
	EXPERIMENT_DATA=$(EXPERIMENT_DATA) \
	envsubst < $(CONFIG) > $(CONFIG).tmp \
	&& eai job new $(INTERACTIVE) -f $(CONFIG).tmp \
	&& rm $(CONFIG).tmp \
	&& eai job logs -f


.PHONY: devbuild
devbuild:
	DOCKER_BUILDKIT=1 docker build . --progress plain -f $(DOCKERFILE_DEV) \
	-t $(TOOLKIT_IMAGE_TAG_DEV)

.PHONY: devpush
devpush: devbuild
	docker push $(TOOLKIT_IMAGE_TAG_DEV)

.PHONY: devsubmit
devsubmit: devpush
	IMAGE_NAME=$(TOOLKIT_IMAGE_TAG_DEV) \
	EXPERIMENT_DATA=$(EXPERIMENT_DATA) \
	envsubst < $(DEV_CONFIG) > $(DEV_CONFIG).tmp \
	&& eai job new -I -f $(DEV_CONFIG).tmp \
	&& rm $(DEV_CONFIG).tmp
