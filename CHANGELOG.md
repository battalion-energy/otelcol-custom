# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.4.0] - 2026-04-30

### Added
- Parameterized the `journald` receiver's `units` list via the `JOURNALD_UNITS` env var (default in `otelcol-custom.conf`), letting sites add per-site units such as `network-syslog` without forking `config.yaml` ([#23](https://github.com/battalion-energy/otelcol-custom/pull/23))
- Lifted `SOURCE_IP`, `SOURCE_HOSTNAME`, `SOURCE_TAG`, `SOURCE_CLASS`, `INGEST_NODE`, and `SYSLOG_IDENTIFIER` from the journal body to log attributes in `transform/journald`, enabling per-device identification of network-syslog events in dash0 ([#23](https://github.com/battalion-energy/otelcol-custom/pull/23))

### Changed
- Bumped OpenTelemetry Collector components from v0.145.0 to v0.151.0 and confmap providers to v1.57.0. Notable upstream fixes picked up: prometheusexporter unbounded memory growth from expired metric families, panic on empty histogram BucketCounts, resourcedetectionprocessor panic on shutdown with multi-pipeline + `refresh_interval`, journaldreceiver no longer emits historical entries on `start_at: end` ([#21](https://github.com/battalion-energy/otelcol-custom/pull/21))
- Bumped GitHub Actions to current majors: `actions/checkout` v6, `actions/upload-artifact` v7, `actions/download-artifact` v8, `softprops/action-gh-release` v3. Removes Node 20 deprecation warnings ([#22](https://github.com/battalion-energy/otelcol-custom/pull/22))

### Fixed
- Removed `aggregate_cpu` from the hostmetrics CPU scraper config (closes [#18](https://github.com/battalion-energy/otelcol-custom/issues/18)) and updated the `otlp-http` exporter alias ([#19](https://github.com/battalion-energy/otelcol-custom/pull/19))

### Upgrade notes
- Sites upgrading from v1.3.x must ensure `JOURNALD_UNITS` is set in `/etc/otelcol-custom/otelcol-custom.conf` before the new `config.yaml` is in place. The dpkg upgrade installs the new `.conf` with a sensible default (`["tailscaled", "batt-edge"]`); manual installs must add the variable themselves.

## [v1.3.0] - 2026-2-10

### Changed
- Upgraded the project toolchain to Go 1.25 and refreshed component versions to the v0.145.x series.
- Updated Go development guidance to match the new toolchain.

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
