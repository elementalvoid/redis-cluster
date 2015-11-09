# Short name: Short name, following [a-zA-Z_], used all over the place.
# Some uses for short name:
# - Docker image name
# - Kubernetes service, rc, pod, secret, volume names
SHORT_NAME := redis

# SemVer with build information is defined in the SemVer 2 spec, but Docker
# doesn't allow +, so we use -.
VERSION := 0.0.1-$(shell date "+%Y%m%d%H%M%S")

# Docker Root FS
BINDIR := ./rootfs

# Legacy support for DEV_REGISTRY, plus new support for DEIS_REGISTRY.
DEV_REGISTRY ?= $(eval docker-machine ip deis):5000
DEIS_REGISTY ?= ${DEV_REGISTRY}

# Kubernetes-specific information for RC, Service, and Image.
MASTER := manifests/${SHORT_NAME}-master.yaml
RC := manifests/${SHORT_NAME}-rc.yaml
SVC := manifests/${SHORT_NAME}-sentinel-service.yaml
SENTINEL_RC := manifests/${SHORT_NAME}-sentinel-rc.yaml

# Docker image name
IMAGE := deis/${SHORT_NAME}:${VERSION}

all: docker-build docker-push

# For cases where we're building from local
# We also alter the RC file to set the image name.
docker-build:
	docker build --rm -t ${IMAGE} rootfs
	perl -pi -e "s|image: .+|image: \"${IMAGE}\"|g" ${MASTER}
	perl -pi -e "s|image: .+|image: \"${IMAGE}\"|g" ${RC}
	perl -pi -e "s|image: .+|image: \"${IMAGE}\"|g" ${SENTINEL_RC}

# Push to a registry that Kubernetes can access.
docker-push:
	docker push ${IMAGE}

# Deploy is a Kubernetes-oriented target
deploy: kube-up

kube-up:
	kubectl create -f ${MASTER}
	kubectl create -f ${SVC}
	kubectl create -f ${RC}
	kubectl create -f ${SENTINEL_RC}

kube-down:
	-kubectl delete -f ${MASTER}
	-kubectl delete -f ${SVC}
	-kubectl delete -f ${RC}
	-kubectl delete -f ${SENTINEL_RC}

.PHONY: all build docker-build docker-push kube-up kube-down deploy
