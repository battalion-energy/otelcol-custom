.PHONY: build clean generate

BINARY_NAME=otelcol
BUILD_DIR=dist

build:
	@echo "Building OpenTelemetry Collector..."
	go run go.opentelemetry.io/collector/cmd/builder@latest --config builder-config.yaml
	cd $(BUILD_DIR) && go build -o $(BINARY_NAME) .

build-linux-amd64:
	@echo "Building for Linux AMD64..."
	go run go.opentelemetry.io/collector/cmd/builder@latest --config builder-config.yaml
	cd $(BUILD_DIR) && GOOS=linux GOARCH=amd64 go build -o $(BINARY_NAME)-linux-amd64 .

build-linux-arm64:
	@echo "Building for Linux ARM64..."
	go run go.opentelemetry.io/collector/cmd/builder@latest --config builder-config.yaml
	cd $(BUILD_DIR) && GOOS=linux GOARCH=arm64 go build -o $(BINARY_NAME)-linux-arm64 .

clean:
	rm -rf $(BUILD_DIR)

generate:
	go run go.opentelemetry.io/collector/cmd/builder@latest --config builder-config.yaml
