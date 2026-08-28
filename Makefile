.PHONY: build clean generate

BINARY_NAME=otelcol
BUILD_DIR=dist

# Keep in sync with the component versions in builder-config.yaml. The builder
# pins the core collector modules to its own version, so @latest here silently
# skews core against the contrib components and the build fails to compile.
BUILDER_VERSION=v0.159.0
BUILDER=go.opentelemetry.io/collector/cmd/builder@$(BUILDER_VERSION)

build:
	@echo "Building OpenTelemetry Collector..."
	go run $(BUILDER) --config builder-config.yaml
	cd $(BUILD_DIR) && go build -o $(BINARY_NAME) .

build-linux-amd64:
	@echo "Building for Linux AMD64..."
	go run $(BUILDER) --config builder-config.yaml
	cd $(BUILD_DIR) && GOOS=linux GOARCH=amd64 go build -o $(BINARY_NAME)-linux-amd64 .

build-linux-arm64:
	@echo "Building for Linux ARM64..."
	go run $(BUILDER) --config builder-config.yaml
	cd $(BUILD_DIR) && GOOS=linux GOARCH=arm64 go build -o $(BINARY_NAME)-linux-arm64 .

clean:
	rm -rf $(BUILD_DIR)

generate:
	go run $(BUILDER) --config builder-config.yaml
