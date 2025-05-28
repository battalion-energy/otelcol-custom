#!/bin/bash

for v in MOUNT_POINTS NETWORK_INTERFACES DASH0_KEY ; do
    [ -n "${!v}" ] || { echo "$v is missing"; exit 1; }
done