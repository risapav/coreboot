# xcompile
xcompile=build/xcompile
objutil=build/util

# adopted from coreboot/coreboot project
export top=$(abspath $(CURDIR)/../..)
export crossgcc_version=$(shell $(top)/util/crossgcc/buildgcc --version | grep 'cross toolchain' | sed 's/^.*\sv//' | sed 's/\s.*$$//')
export DOCKER:=$(shell $(SHELL) -c "command -v docker")

# Version of the jenkins / sdk container
export COREBOOT_IMAGE_TAG?=2021-12-29_ce134ababd
# export COREBOOT_IMAGE_TAG?=$(crossgcc_version)

# Commit id to build from
export DOCKER_COMMIT?=$(shell git log -n 1 --pretty=%h)
export COREBOOT_CROSSGCC_PARAM?="build-arm build-i386 build-x64 build_gcc build_iasl build_nasm"

# .ccache dir to use
export DOCKER_CCACHE?=$(HOME)/.ccache

SCRIPT ?= "bash -l"

HOME ?= "/home/coreboot"

UID ?= $(shell id -u)
GID ?= $(shell id -g)

test-docker:
	$(if $(DOCKER),,\
		$(warning Error: Docker command not found.  Please install docker) \
		$(warning Instructions: https://docs.docker.com/engine/install/ ) \
		$(error halting))
		
clean-coreboot-containers: docker-killall
	@if [ -n "$$($(DOCKER) ps -a | grep 'coreboot')" ]; then \
		$(DOCKER) rm $$($(DOCKER) ps -a | grep 'coreboot' | sed 's|\s.*$$||'); \
	fi

clean-coreboot-images: docker-killall
	@if [ -n "$$($(DOCKER) images | grep 'coreboot')" ]; then \
		$(DOCKER) rmi $$($(DOCKER) images | grep coreboot | sed 's|^\S\+\s\+\S\+\s\+||' | sed 's|\s.*$$||'); \
	fi

coreboot-sdk: test-docker
	@echo "Building coreboot SDK $(crossgcc_version) from commit $(DOCKER_COMMIT)"
	cat coreboot-sdk/Dockerfile | \
		sed "s/{{DOCKER_COMMIT}}/$(DOCKER_COMMIT)/g" | \
		sed "s/{{SDK_VERSION}}/$(COREBOOT_IMAGE_TAG)/g" | \
		sed "s/{{CROSSGCC_PARAM}}/$(COREBOOT_CROSSGCC_PARAM)/g" | \
		$(DOCKER) build -t coreboot/coreboot-sdk:$(COREBOOT_IMAGE_TAG) -

docker-clean: clean-coreboot-containers
	@$(MAKE) clean-coreboot-images

$(DOCKER_CCACHE):
	@mkdir -p $@

docker-run-local: test-docker $(DOCKER_CCACHE)
	$(DOCKER) run \
		-it \
		-u $(UID):$(GID) \
		-e COLUMNS=$(shell tput cols) \
		-e LINES=$(shell tput lines) \
		-e TERM=$(TERM) \
		-v $(CURDIR):/home/coreboot \
		-v $(CURDIR)/.ccache:/home/coreboot/.ccache \
		--rm coreboot/coreboot-sdk:$(COREBOOT_IMAGE_TAG) \
		$(SCRIPT)
#		/bin/bash -c 'cd /home/coreboot && $(DOCKER_RUN_LOCAL)'
#		-v $(DOCKER_CCACHE):/home/coreboot/.ccache \
# $(SCRIPT)

docker-shell: USER=coreboot
docker-shell: test-docker
	$(DOCKER) run -u $(USER) -it  \
		-u $(UID):$(GID) \
		-v $(CURDIR):/home/coreboot \
		-e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) -e TERM=$(TERM) \
		-w /home/coreboot \
		--rm coreboot/coreboot-sdk:$(COREBOOT_IMAGE_TAG) \
		/bin/bash -l
		
#		-v $(DOCKER_CCACHE):/home/coreboot/.ccache \		
		
docker-build-coreboot: docker-run-local
docker-build-coreboot: override DOCKER_RUN_LOCAL := \
	make clean && make $(BUILD_CMD)
		
help:
	@echo "Commands for working with docker images:"
	@echo "  coreboot-sdk                 - Build coreboot-sdk container"
	@echo "  clean-coreboot-containers    - Remove all docker coreboot containers"
	@echo "  clean-coreboot-images        - Remove all docker coreboot images"
	@echo "  docker-clean                 - Remove docker coreboot containers & images"
	@echo
	@echo "Commands for using docker images"
	@echo "  docker-build-coreboot        - Build coreboot under coreboot-sdk"
	@echo "      <BUILD_CMD=target> "
	@echo "  docker-abuild                - Run abuild under coreboot-sdk"
	@echo "      <ABUILD_ARGS='-a -B'>"
	@echo "  docker-shell                 - Bash prompt in coreboot-jenkins-node"
	@echo "      <USER=root or USER=coreboot>"
	@echo "  docker-build-docs            - Build the documentation"
	@echo
	@echo "Variables:"
	@echo "  COREBOOT_IMAGE_TAG=$(COREBOOT_IMAGE_TAG)"
	@echo "  DOCKER_COMMIT=$(DOCKER_COMMIT)"
	@echo "  crossgcc_version=$(crossgcc_version)"
	@echo "  top=$(top)"
	@echo "  DOCKER=$(DOCKER)"


.PHONY: test-docker coreboot-sdk
.PHONY: docker-clean 
.PHONY: docker-run-local docker-build-coreboot
.PHONY: docker-shell
.PHONY: clean-coreboot-containers clean-coreboot-images
.PHONY: help
