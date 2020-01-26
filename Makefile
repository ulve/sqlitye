.PHONY: build run help

DEFAULT_GOAL: help

PROJECT_NAME ?= $(shell grep "^name" sqlitye.cabal | cut -d " " -f17)
VERSION ?= $(shell grep "^version:" sqlitye.cabal | cut -d " " -f14)
RESOLVER ?= $(shell grep "^resolver:" stack.yaml | cut -d " " -f2)
GHC_VERSION ?= $(shell stack ghc -- --version | cut -d " " -f8)
ARCH=$(shell uname -m)

export LOCAL_USER_ID ?= $(shell id -u $$USER)
export BINARY_ROOT = $(shell stack path --local-install-root)
export BINARY_PATH = $(shell echo ${BINARY_ROOT}/bin/${PROJECT_NAME})
export BINARY_PATH_RELATIVE = $(shell BINARY_PATH=${BINARY_PATH} python -c "import os; p = os.environ['BINARY_PATH']; print os.path.relpath(p).strip()")

## Build binary and docker images
build:
	@BINARY_PATH=${BINARY_PATH_RELATIVE} docker-compose build

## Run the app
run:
	@LOCAL_USER_ID=${LOCAL_USER_ID} docker-compose up

## Show help screen.
help:
	@echo "Please use \`make <target>' where <target> is one of\n\n"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-30s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

