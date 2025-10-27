# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [v1.2.0] - 2025-10-27

### Added
- Added Prometheus receiver and exporter pipelines for batt-edge metrics with configurable scrape and exposure endpoints ([#6](https://github.com/battalion-energy/otelcol-custom/pull/6), [#12](https://github.com/battalion-energy/otelcol-custom/pull/12))
- Added a Go development guide to document the local build workflow and tooling expectations ([#7](https://github.com/battalion-energy/otelcol-custom/pull/7))
- Added a manual installation guide for installing the Debian packages outside the release workflow ([#14](https://github.com/battalion-energy/otelcol-custom/pull/14))

### Changed
- Upgraded the OpenTelemetry Collector builder dependencies and project toolchain to Go 1.24 with refreshed module versions ([#7](https://github.com/battalion-energy/otelcol-custom/pull/7))
- Replaced the release-only GitHub Actions workflow with a unified CI pipeline that builds, validates configs, and publishes release artifacts ([#10](https://github.com/battalion-energy/otelcol-custom/pull/10))

## [v1.1.1] - 2025-05-29

### Fixed
- Preserve otelcol-custom.conf during package upgrades ([#5](https://github.com/jadamcrain/otelcol-custom/pull/5))

## [v1.1.0] - 2025-05-28

### Changed
- Re-enabled process.memory.usage metric collection
- Updated release instructions documentation

### Added
- Added site_name variable to configuration file (#4)

### Fixed
- Removed superfluous text from release body formatting

## [v1.0.0] - 2025-05-28

### Added
- Initial release of Custom OpenTelemetry Collector
- Debian package support for amd64 and arm64 architectures
- Systemd service configuration
- Basic configuration templates
