GO           ?= go
GOFMT        ?= $(GO)fmt
NPM          ?= npm
NPX          ?= npx
RHINO        ?= rhino
pkgs          = ./...
PKGER        ?= pkger


help: Makefile
	@echo
	@echo " Choose a command run in Peanut:"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo


## install_revive: Install revive for linting.
.PHONY: install_revive
install_revive:
	@echo ">> ============= Install Revive ============= <<"
	$(GO) get github.com/mgechev/revive


## style: Check code style.
.PHONY: style
style:
	@echo ">> ============= Checking Code Style ============= <<"
	@fmtRes=$$($(GOFMT) -d $$(find . -path ./vendor -prune -o -name '*.go' -print)); \
	if [ -n "$${fmtRes}" ]; then \
		echo "gofmt checking failed!"; echo "$${fmtRes}"; echo; \
		echo "Please ensure you are using $$($(GO) version) for formatting code."; \
		exit 1; \
	fi


## check_license: Check if license header on all files.
.PHONY: check_license
check_license:
	@echo ">> ============= Checking License Header ============= <<"
	@licRes=$$(for file in $$(find . -type f -iname '*.go' ! -path './vendor/*') ; do \
			   awk 'NR<=3' $$file | grep -Eq "(Copyright|generated|GENERATED)" || echo $$file; \
	   done); \
	   if [ -n "$${licRes}" ]; then \
			   echo "license header checking failed:"; echo "$${licRes}"; \
			   exit 1; \
	   fi


## test_short: Run test cases with short flag.
.PHONY: test_short
test_short:
	@echo ">> ============= Running Short Tests ============= <<"
	$(GO) clean -testcache
	$(GO) test -mod=readonly -short $(pkgs)


## test: Run test cases.
.PHONY: test
test:
	@echo ">> ============= Running All Tests ============= <<"
	$(GO) clean -testcache
	$(GO) test -mod=readonly -run=Unit -bench=. -benchmem -v -cover $(pkgs)


## integration: Run integration test cases (Requires etcd)
.PHONY: integration
integration:
	@echo ">> ============= Running All Tests ============= <<"
	$(GO) clean -testcache
	$(GO) test -mod=readonly -run=Integration -bench=. -benchmem -v -cover $(pkgs)


## lint: Lint the code.
.PHONY: lint
lint:
	@echo ">> ============= Lint All Files ============= <<"
	revive -config config.toml -exclude vendor/... -formatter friendly ./...


## verify: Verify dependencies
.PHONY: verify
verify:
	@echo ">> ============= List Dependencies ============= <<"
	$(GO) list -m all
	@echo ">> ============= Verify Dependencies ============= <<"
	$(GO) mod verify


## format: Format the code.
.PHONY: format
format:
	@echo ">> ============= Formatting Code ============= <<"
	$(GO) fmt $(pkgs)


## vet: Examines source code and reports suspicious constructs.
.PHONY: vet
vet:
	@echo ">> ============= Vetting Code ============= <<"
	$(GO) vet $(pkgs)


## coverage: Create HTML coverage report
.PHONY: coverage
coverage:
	@echo ">> ============= Coverage ============= <<"
	rm -f coverage.html cover.out
	$(GO) test -mod=readonly -coverprofile=cover.out $(pkgs)
	go tool cover -html=cover.out -o coverage.html


## serve_ui: Serve admin dashboard
.PHONY: serve_ui
serve_ui:
	@echo ">> ============= Run Vuejs App ============= <<"
	cd web;$(NPM) run serve


## build_ui: Builds admin dashboard for production
.PHONY: build_ui
build_ui:
	@echo ">> ============= Build Vuejs App ============= <<"
	cd web;$(NPM) run build


## check_ui_format: Check dashboard code format
.PHONY: check_ui_format
check_ui_format:
	@echo ">> ============= Validate js format ============= <<"
	cd web;$(NPX) prettier  --check .


## format_ui: Format dashboard code
.PHONY: format_ui
format_ui:
	@echo ">> ============= Format js Code ============= <<"
	cd web;$(NPX) prettier  --write .


## package: Package assets
.PHONY: package
package:
	@echo ">> ============= Package Assets ============= <<"
	-rm $(shell pwd)/web/.env
	echo "VUE_APP_API_URL=" > $(shell pwd)/web/.env.dist
	cd web;$(NPM) run build
	$(PKGER) list -include $(shell pwd)/web/dist
	$(PKGER) -o cmd


## run: Run the API Server
.PHONY: run
run:
	@echo ">> ============= Run Tower ============= <<"
	$(GO) run peanut.go api -c config.dist.yml


## ci: Run all CI tests.
.PHONY: ci
ci: style check_license test vet lint
	@echo "\n==> All quality checks passed"


.PHONY: help
