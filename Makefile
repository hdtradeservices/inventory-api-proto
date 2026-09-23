OUTPUT_DIR=go
GO_BUILD_DIR=${BUILD_DIR}/github.com/hdtradeservices/inventory-api-proto/go
OPEN_API_V2=openapiv2
DOCS_BUILD_DIR=docs

PROTO_SRC=src

# -e makes every recipe line fail on its first failing command, so a protoc
# error fails `make build` instead of being swallowed.
SHELL := /bin/bash
.SHELLFLAGS := -ec

# Pinned inputs. The plugins stay at grpc-gateway v2.6.0, but the options-proto
# clone is the v2.12.0 tag: the protos set openapiv2 Tag.name, added in v2.12.0.
GOOGLEAPIS_REF := 5e89775233124f32303f6acad821bf8e90973219
GRPC_GATEWAY_REF := 1dac1ac6439c7e32714601b945e84f21b23d9cbd
PROTOC_GEN_DOC_VERSION := v1.5.1
PROTOLINT_VERSION := v0.34.0

# $(call fetch_pinned,<dir>,<repo url>,<commit sha>): shallow-fetch one commit
# into <dir>, reusing <dir> when it is already at that commit.
define fetch_pinned
	if [ "$$(git -C $(1) rev-parse -q --verify HEAD 2>/dev/null)" != "$(3)" ]; then \
		rm -rf $(1); \
		git init -q $(1); \
		git -C $(1) fetch -q --depth 1 $(2) $(3); \
		git -C $(1) checkout -q FETCH_HEAD; \
	fi
endef

all: build

build: tools clean
	mkdir -p $(OUTPUT_DIR) $(OPEN_API_V2) $(DOCS_BUILD_DIR)
	cd $(PROTO_SRC) && \
		protoc inventory_api/**/*.proto \
		-I ../googleapis/ \
		-I ../grpc-gateway/ \
		-I ../src/ \
		--openapiv2_out ../openapiv2 \
		--openapiv2_opt logtostderr=true \
		--openapiv2_opt use_go_templates=true \
		--go_out=../$(OUTPUT_DIR) \
		--go_opt=paths=source_relative \
		--go-grpc_out=require_unimplemented_servers=false,paths=source_relative:../$(OUTPUT_DIR) \
		--grpc-gateway_out=../$(OUTPUT_DIR) \
		--grpc-gateway_opt logtostderr=true \
		--grpc-gateway_opt paths=source_relative \
		--doc_out=:../$(DOCS_BUILD_DIR) \
		--doc_opt=markdown,full-reference.md
	rm -rf googleapis grpc-gateway

check-update:
	@git diff --exit-code
	@git status --porcelain
	@test -z "$(shell git status --porcelain)"

clean:
	find ${OUTPUT_DIR} -type f -name '*.pb.go' -delete || true
	rm -rf ${DOCS_BUILD_DIR} || true
	rm -rf ${OPEN_API_V2} || true

format:
	gofmt -w $(OUTPUT_DIR)

check-fmt:
	@unformatted="$$(gofmt -l $(OUTPUT_DIR))"; \
	if [ -n "$$unformatted" ]; then \
		echo "gofmt needed (run make format):"; \
		echo "$$unformatted"; \
		exit 1; \
	fi

test: tools
	go test ./go/...

tools:
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v2.6.0
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v2.6.0
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.26.0
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1
	go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@$(PROTOC_GEN_DOC_VERSION)
	go install github.com/yoheimuta/protolint/cmd/protolint@$(PROTOLINT_VERSION)
	$(call fetch_pinned,googleapis,https://github.com/googleapis/googleapis.git,$(GOOGLEAPIS_REF))
	$(call fetch_pinned,grpc-gateway,https://github.com/grpc-ecosystem/grpc-gateway.git,$(GRPC_GATEWAY_REF))

lint:
	protolint src

lint-fix:
	protolint lint -fix src

.PHONY: all build check-fmt check-update clean format test tools lint lint-fix
