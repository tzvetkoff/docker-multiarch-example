# All supported architectures
ARCH_ALL := amd64 arm64

# Default architecture
ARCH := amd64

# Image name
NAME := tzvetkoff/food-for-thought

# Version
VERSION := 0.1.0

# Image and version
IMAGE := $(NAME):$(VERSION)

# Use bash instead of sh
SHELL := /bin/bash

## Print this message and exit
.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | awk '														\
		/^([0-9a-z-]+):.*$$/ {															\
			if (description[0] != "") {													\
				printf("\x1b[36mmake %s\x1b[0m\n", substr($$1, 0, length($$1)-1));		\
				for (i in description) {												\
					printf("| %s\n", description[i]);									\
				}																		\
				printf("\n");															\
				split("", description);													\
				descriptionIndex = 0;													\
			}																			\
		}																				\
		/^##/ {																			\
			description[descriptionIndex++] = substr($$0, 4);							\
		}																				\
	'

## Build a single-architecture image
.PHONY: build
build:
	docker buildx build . \
		--platform linux/$(ARCH) \
		--file Dockerfile.$(ARCH) \
		--tag $(IMAGE).$(ARCH)

## Push a single-architecture image
.PHONY: push
push:
	docker push $(IMAGE).$(ARCH)

## Build image for all architectures
.PHONY: build-all
build-all:
	for ARCH in $(ARCH_ALL); do \
		docker buildx build . \
			--platform linux/$${ARCH} \
			--file Dockerfile.$${ARCH} \
			--tag $(IMAGE).$${ARCH}; \
	done

## Push image for all architectures
.PHONY: push-all
push-all:
	command=(docker manifest create $(IMAGE)); \
	for ARCH in $(ARCH_ALL); do \
		docker push $(IMAGE).$${ARCH}; \
		command+=(--amend $(IMAGE).$${ARCH}); \
	done; \
	echo "$${command[@]}"; \
	"$${command[@]}" && docker manifest push $(IMAGE)

# vim:ft=make:ts=4:sts=4:noet
