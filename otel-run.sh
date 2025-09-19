#!/bin/bash
export PROMETHEUS_EXPORTER_ENDPOINT=0.0.0.0:9464
export MOUNT_POINTS='["/"]'
export NETWORK_INTERFACES='["wlp2s0"]'
export DASH0_API_KEY=dummy
export SITE_NAME=dev-laptop
export METRICS_SCRAPE_INTERVAL=30s
export METRICS_BATCH_INTERVAL=5s

otelcol-contrib --config config.yaml
