ORG_PATH=github.com/Azure
PROJECT_NAME := aad-pod-identity
REPO_PATH="$(ORG_PATH)/$(PROJECT_NAME)"
NMI_BINARY_NAME := nmi
NMI_VERSION=1.0
VERSION_VAR := $(REPO_PATH)/version.Version
GIT_VAR := $(REPO_PATH)/version.GitCommit
BUILD_DATE_VAR := $(REPO_PATH)/version.BuildDate
BUILD_DATE := $$(date +%Y-%m-%d-%H:%M)
GIT_HASH := $$(git rev-parse --short HEAD)

ifeq ($(OS),Windows_NT)
	GO_BUILD_MODE = default
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S), Linux)
		GO_BUILD_MODE = pie
	endif
	ifeq ($(UNAME_S), Darwin)
		GO_BUILD_MODE = default
	endif
endif

GO_BUILD_OPTIONS := -buildmode=${GO_BUILD_MODE} -ldflags "-s -X $(VERSION_VAR)=$(NMI_VERSION) -X $(GIT_VAR)=$(GIT_HASH) -X $(BUILD_DATE_VAR)=$(BUILD_DATE)"

# useful for other docker repos
REGISTRY ?= nikhilbh
IMAGE_NAME := $(REGISTRY)/$(NMI_BINARY_NAME)

clean:
	rm -rf bin/$(PROJECT_NAME)

build:clean
	go build -o bin/$(PROJECT_NAME)/$(NMI_BINARY_NAME) $(GO_BUILD_OPTIONS) github.com/Azure/$(PROJECT_NAME)/cmd/$(NMI_BINARY_NAME)

image:
	cp bin/$(PROJECT_NAME)/$(NMI_BINARY_NAME) images/nmi
	docker build -t $(IMAGE_NAME):$(NMI_VERSION) images/nmi

push:
	docker push $(IMAGE_NAME):$(NMI_VERSION)

.PHONY: build