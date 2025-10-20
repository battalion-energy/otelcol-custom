# Custom OpenTelemetry Collector

A custom build of the OpenTelemetry Collector optimized for reduced size and memory usage by including only the necessary components for production workloads.

## Overview

This repository builds a streamlined version of the OpenTelemetry Collector that excludes unnecessary receivers, processors, and exporters. By removing unused components, we achieve:

- **Reduced binary size** - Smaller executable footprint
- **Lower memory usage** - Less RAM consumption in production
- **Faster startup times** - Fewer components to initialize
- **Improved security** - Smaller attack surface with fewer dependencies

## Components

The custom collector is built using the [OpenTelemetry Collector Builder](https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder) with a curated set of components defined in `builder-config.yaml`.

## Installation

### Debian/Ubuntu Systems

1. Download the appropriate `.deb` package from the [releases page](https://github.com/battalion-energy/otelcol-custom/releases)
2. Install the package:
   ```bash
   sudo dpkg -i otelcol-custom_1.0.0_amd64.deb
   ```
3. The service will be automatically enabled and started
4. Check the service status:
   ```bash
   sudo systemctl status otelcol-custom
   ```

### Configuration

The collector configuration is located at `/etc/otelcol-custom/config.yaml`. The default configuration can be customized for your specific use case.

Service configuration options are available in `/etc/otelcol-custom/otelcol-custom.conf`.

## Development

### Building Locally

1. Ensure you have Go 1.23+ installed
2. Generate the collector code:
   ```bash
   go run go.opentelemetry.io/collector/cmd/builder@latest --config builder-config.yaml
   ```
3. Build the binary:
   ```bash
   cd dist
   go build -ldflags="-s -w" -o ../otelcol-custom .
   ```
### Dependency updates
OpenTelemetry Collector tends to be on a fast release cycle, so keeping the dependencies up to date is a good idea.
1) Make sure to grab the latest versions of the dependencies:
```bash
   go get \
    go.opentelemetry.io/collector/cmd/builder@[latest] \
    go.opentelemetry.io/collector/component@[latest] \
    go.opentelemetry.io/collector/confmap@[latest] \
    go.opentelemetry.io/collector/otelcol@[latest]

  go mod tidy # This is used to remove any indirect deps that aren't needed anymore
```
2) Update the `builder-config.yaml` to the versions added above.
   Small example:
   ```go
   receivers:
      - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/journaldreceiver [latest version] // <- update the version
   ```
3) Make sure everything works with `make build` and `./dist/otelcol --config config.yaml`

### Creating Debian Packages

Use the included build script to create Debian packages:

```bash
./build-deb.sh otelcol-custom amd64
```

This will create a `.deb` package with proper systemd service integration.

## Service Management

The collector runs as a systemd service with the following commands:

```bash
# Start the service
sudo systemctl start otelcol-custom

# Stop the service
sudo systemctl stop otelcol-custom

# Restart the service
sudo systemctl restart otelcol-custom

# View logs
sudo journalctl -u otelcol-custom -f
```

## Files and Locations

- **Binary**: `/usr/bin/otelcol-custom`
- **Configuration**: `/etc/otelcol-custom/config.yaml`
- **Environment**: `/etc/otelcol-custom/otelcol-custom.conf`
- **Pre-start script**: `/usr/bin/otelcol-exec-start-pre.sh`
- **Service file**: `/etc/systemd/system/otelcol-custom.service`

## License

This project follows the same license as the OpenTelemetry Collector project.