SHELL := /usr/bin/env bash

IMAGENAME=edbchefinspec:5.22.3
IMAGEREPO=edb-docker-dev-local.artifactory.aws.nbscloud.co.uk/pace-test/$(IMAGENAME)
WORKDIR=/share

DOCKERBUILD=docker build -t $(IMAGEREPO) .
COMMAND=docker run -it -v ~/.kube:/root/.kube -v ~/.aws:/root/.aws --env KUBECONFIG=~/.kube/config -e AWS_SDK_JS_SUPPRESS_MAINTENANCE_MODE_MESSAGE='1' --rm   
IMAGEPATH=$(IMAGEREPO)
INSPECRUN=$(COMMAND) $(IMAGEPATH) exec . -t k8s://
DEBUGSHELL=$(COMMAND) --entrypoint /bin/bash $(IMAGEPATH)

build:
	@echo "Building $(IMAGEREPO):latest"
	@$(DOCKERBUILD)
run:
	@echo "Running in $(IMAGEREPO) inspec exec . -t k8s://"
	@$(INSPECRUN)
shell:
	@echo "Running a shell inside the container"
	@$(DEBUGSHELL)

.PHONY: build run shell
