# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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