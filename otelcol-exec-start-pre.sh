#!/bin/bash

for v in MOUNT_POINTS NETWORK_INTERFACES DASH0_API_KEY METRICS_SCRAPE_INTERVAL METRICS_BATCH_INTERVAL; do
    [ -n "${!v}" ] || { echo "$v is missing"; exit 1; }
done