export GOBIN ?= $(shell pwd)/bin

GOLINT = $(GOBIN)/golint

GO_FILES := $(shell \
	find . '(' -path './go/.*' -o -path './athenareader'  ')' -prune \
	-o -name '*.go' -print | cut -b3-)

.PHONY: build
build:
	go build github.com/mrz1836/athenadriver/go

.PHONY: install
install:
	go mod download

.PHONY: dependencies
dependencies:
	go mod download

.PHONY: checklic
checklic:
	@echo "Checking for license headers..."
	@cd scripts && ./checklic.sh | tee -a ../lint.log

.PHONY: test
test:
	GOPRIVATE="github.com/mrz1836" go test github.com/mrz1836/athenadriver/go

.PHONY: cover
cover:
	GOPRIVATE="github.com/mrz1836" go test -race -coverprofile=cover.out -coverpkg=github.com/mrz1836/athenadriver/go/... github.com/mrz1836/athenadriver/go/...
	GOPRIVATE="github.com/mrz1836" go tool cover -html=cover.out -o cover.html

$(GOLINT):
	go install golang.org/x/lint/golint

.PHONY: lint
lint: $(GOLINT)
	@rm -rf lint.log
	@echo "Checking formatting..."
	@gofmt -d -s $(GO_FILES) 2>&1 | tee lint.log
	@echo "Checking vet..."
	@go vet github.com/mrz1836/athenadriver/go/... 2>&1 | tee -a lint.log
	@echo "Checking lint..."
	@$(GOLINT) github.com/mrz1836/athenadriver/go/... | tee -a lint.log
	@$(GOLINT) github.com/mrz1836/athenadriver/athenareader/... | tee -a lint.log
	@echo "Checking for unresolved FIXMEs..."
	@git grep -i fixme | grep -v -e vendor -e Makefile -e .md | tee -a lint.log
	@[ ! -s lint.log ]
