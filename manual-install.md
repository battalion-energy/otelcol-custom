# otelcol-custom — Manual Install (in case of dpkg fallback)

This is the manual installation path for `otelcol-custom` when the `.deb` install via `dpkg` isn’t an option. It mirrors what the package would have done, but without touching the system package database.

> **Note:** You’re bypassing your OS package manager. Keep track of what you put where so you can cleanly remove or upgrade later.

## Table of Contents

1. [Why manual install? (What the .deb does)](#why-manual-install-what-the-deb-does)
2. [Common dpkg failure modes](#common-dpkg-failure-modes)
3. [Prerequisites](#prerequisites)
4. [Expected layout](#expected-layout)
5. [Install steps](#install-steps)
6. [Configure](#configure)
7. [Manage the service](#manage-the-service)
8. [Verify](#verify)
9. [Troubleshooting](#troubleshooting)
10. [Service commands reference](#service-commands-reference)
11. [Uninstall](#uninstall)
12. [Additional resources & support](#additional-resources--support)

## What dpkg does

A Debian package (`.deb`) is an `ar` archive with three members:

```
debian-binary    → format version (typically "2.0")
control.tar.*    → metadata + maintainer scripts
data.tar.*       → payload (the files to install)
```

> Quick peek tools:
>
> ```bash
> ar t package.deb
> dpkg-deb --info package.deb   # metadata
> dpkg-deb --contents package.deb  # file list
> ```

When you run `sudo dpkg -i package.deb`, `dpkg` performs (roughly) the following:

1. **Extract & read metadata**
   Unpacks the archive and reads `control.tar.*`, which includes:

   - Package identity: name, version, architecture
   - Dependency declarations
   - Description, maintainer info
   - Maintainer scripts: `preinst`, `postinst`, `prerm`, `postrm` (and optional triggers)

2. **Check suitability**
   Verifies architecture and whether required packages are present.

   > Note: `dpkg` **does not** resolve dependencies; `apt` does. Missing deps cause the install to fail until you fix them (often with `sudo apt-get -f install`).

3. **Unpack payload**
   Installs files from `data.tar.*` into their target locations rooted at `/` (e.g., `usr/bin/app` ends up at `/usr/bin/app`), applying ownership and modes from the tarball.

4. **Run maintainer scripts**
   Executes lifecycle hooks in order (e.g., `preinst` before unpack, `postinst` after) to do things like create users, write generated config, run `systemctl daemon-reload`, enable services, etc.

5. **Register with the package database**
   Updates `/var/lib/dpkg/status` and writes package artifacts under `/var/lib/dpkg/info/`:

   - `<pkg>.list` (installed file list)
   - `<pkg>.postinst`, `<pkg>.preinst`, etc.
   - `<pkg>.md5sums`, and related bookkeeping

---

### What our `.deb` would do for `otelcol-custom`

The project’s `build-deb.sh` produces a package that, when installed, would:

- Install the collector: `/usr/bin/otelcol-custom`
- Install the pre‑start validation script: `/usr/bin/otelcol-exec-start-pre.sh`
- Place configuration under `/etc/otelcol-custom/`:

  - `config.yaml`
  - `otelcol-custom.conf` (environment for the service)

- Install the systemd unit: `/etc/systemd/system/otelcol-custom.service`
- Run the necessary hooks to reload systemd, enable the unit, and start the service

**Manual installation** simply reproduces those effects without registering anything in `dpkg`—i.e., we place the same files in the same locations, set sane permissions, reload systemd, enable, and start the unit.

## Common dpkg failure modes

- Missing/conflicting dependencies
- Insufficient privileges for system paths
- Corrupt/incomplete `.deb`
- Low disk space
- Postinst/preinst script errors
- Service/port conflicts
- Architecture mismatch (e.g., `arm64` vs `amd64`)

Often `sudo apt-get -f install` cleans up dependency issues. If not, continue below.

## Prerequisites

- Root or `sudo` access
- A `otelcol-custom` binary built for the target architecture
- Config files from this repo
- A systemd‑based Linux distro

> **Tip:** Confirm arch before you move binaries:
>
> ```bash
> uname -m
> file dist/otelcol
> ```

## Expected layout

```
/usr/bin/
├── otelcol-custom                    # Main collector binary
└── otelcol-exec-start-pre.sh         # Pre-start validation script

/etc/otelcol-custom/
├── config.yaml                       # Collector config
└── otelcol-custom.conf               # Environment for the service

/etc/systemd/system/
└── otelcol-custom.service            # systemd unit
```

## Install steps

> Prefer `install(1)` for atomic permissions/ownership vs `cp` + `chmod`.

1. **Build (if needed)**

```bash
# Build for current machine
make build

# Or cross-build
make build-linux-amd64   # x86_64
make build-linux-arm64   # aarch64
```

The binary should land in `dist/`.

2. **Create directories**

```bash
sudo mkdir -p /etc/otelcol-custom
# /usr/bin and /etc/systemd/system already exist on most systems
```

3. **Install binaries**

```bash
# Collector
sudo install -o root -g root -m 0755 dist/otelcol /usr/bin/otelcol-custom

# Pre-start validation script
sudo install -o root -g root -m 0755 otelcol-exec-start-pre.sh /usr/bin/otelcol-exec-start-pre.sh
```

4. **Install configuration**

```bash
sudo install -o root -g root -m 0644 config.yaml /etc/otelcol-custom/config.yaml
sudo install -o root -g root -m 0644 otelcol-custom.conf /etc/otelcol-custom/otelcol-custom.conf
sudo install -o root -g root -m 0644 otelcol-custom.service /etc/systemd/system/otelcol-custom.service
```

> **Sanity check:** Ensure the unit references your env file and pre‑start script:
>
> ```bash
> systemctl cat otelcol-custom | sed -n '1,200p'
> # Look for:
> # EnvironmentFile=/etc/otelcol-custom/otelcol-custom.conf
> # ExecStartPre=/usr/bin/otelcol-exec-start-pre.sh
> ```

## Configure

### 1) Environment

Edit `/etc/otelcol-custom/otelcol-custom.conf`:

```bash
sudo ${EDITOR:-nano} /etc/otelcol-custom/otelcol-custom.conf
```

**Required variables (examples):**

```bash
# Collector CLI options
OTELCOL_OPTIONS="--config=/etc/otelcol-custom/config.yaml"

# Arrays-as-strings parsed by the pre-start script
MOUNT_POINTS="['/', '/var/log']"
NETWORK_INTERFACES="['eth0', 'eth1']"

# Export auth and identity
DASH0_API_KEY="Bearer <your-api-key-here>"
SITE_NAME="<your-site-name>"

# Metrics cadence
METRICS_SCRAPE_INTERVAL="30s"
METRICS_BATCH_INTERVAL="15m"

# Prometheus scrape/export
PROMETHEUS_EXPORTER_ENDPOINT="0.0.0.0:8889"
PROMETHEUS_TARGETS="['localhost:9090']"
```

> **Note:** `otelcol-custom.conf` is consumed by systemd as an `EnvironmentFile` and may also be sourced by scripts. Keep it to simple `KEY="value"` lines and avoid shell syntax that relies on complex evaluation.

### 2) Validate env & config

Run the pre‑start check the same way systemd would load it:

```bash
sudo bash -c 'source /etc/otelcol-custom/otelcol-custom.conf && /usr/bin/otelcol-exec-start-pre.sh'
```

Then validate the collector config:

```bash
sudo /usr/bin/otelcol-custom --config=/etc/otelcol-custom/config.yaml validate
```

## Manage the service

```bash
# Pick up the new unit
sudo systemctl daemon-reload

# Enable on boot and start now
sudo systemctl enable --now otelcol-custom.service

# Status
sudo systemctl status otelcol-custom.service
```

Expected:

```
● otelcol-custom.service - OpenTelemetry Collector Contrib
     Loaded: loaded (/etc/systemd/system/otelcol-custom.service; enabled)
     Active: active (running) since ...
```

## Verify

**Logs (live):**

```bash
sudo journalctl -u otelcol-custom.service -f
```

**Recent logs:**

```bash
sudo journalctl -u otelcol-custom.service -n 100
```

**Process present:**

```bash
pgrep -a otelcol-custom
```

**Ports/listeners:**

```bash
sudo ss -tlnp | grep otelcol-custom
# or, if installed:
sudo netstat -tlnp | grep otelcol-custom
```

**Prometheus exporter (if enabled):**

```bash
curl http://localhost:8889/metrics
```

**Exporter health (Dash0):**

```bash
sudo journalctl -u otelcol-custom.service | grep -i "error\|failed\|connection"
```

## Troubleshooting

### Service won’t start

1. **Pre‑start validation failed**

   ```bash
   sudo journalctl -u otelcol-custom.service | grep "is missing"
   ```

   Fix the missing vars in `/etc/otelcol-custom/otelcol-custom.conf`.

2. **Config invalid**

   ```bash
   sudo /usr/bin/otelcol-custom --config=/etc/otelcol-custom/config.yaml validate
   ```

   Correct YAML errors and retry.

3. **Permissions wrong**

   ```bash
   ls -l /usr/bin/otelcol-custom /usr/bin/otelcol-exec-start-pre.sh
   ls -l /etc/otelcol-custom/ /etc/systemd/system/otelcol-custom.service
   ```

   Ensure root:root, `0755` for binaries, `0644` for configs/units.

### Service starts, then crashes

- **Check detailed logs**

  ```bash
  sudo journalctl -u otelcol-custom.service -n 200
  ```

- **Common causes**

  - Wrong interface name(s): `ip link show`
  - Missing mount points: `df -h`
  - Journald unavailable: ensure `/var/log/journal` exists if required
  - Bad API key: verify `DASH0_API_KEY`

### Metrics aren’t showing up

- Ensure the things you expect to scrape/measure actually exist and are reachable.

  ```bash
  # Example checks
  ip link show
  df -h
  curl -sS http://localhost:9090/-/ready || true
  ```

### Data not reaching Dash0

```bash
# Connectivity to ingress
curl -I https://ingress.us-west-2.aws.dash0.com/

# Log export errors
sudo journalctl -u otelcol-custom.service | grep -i "dash0\|export"
```

### Can’t stop the service

```bash
sudo systemctl stop otelcol-custom.service || true
sudo systemctl kill -s SIGKILL otelcol-custom.service || true
sudo pkill -9 otelcol-custom || true
```

### Reload config without full restart

```bash
sudo systemctl reload otelcol-custom.service
```

> **Note:** Reload behavior depends on your collector build/version; if `SIGHUP` isn’t supported, do a `restart`.

## Service commands reference

```bash
# Lifecycle
sudo systemctl start    otelcol-custom.service
sudo systemctl stop     otelcol-custom.service
sudo systemctl restart  otelcol-custom.service
sudo systemctl reload   otelcol-custom.service
sudo systemctl status   otelcol-custom.service

# Enable/disable at boot
sudo systemctl enable   otelcol-custom.service
sudo systemctl disable  otelcol-custom.service

# Logs
sudo journalctl -u otelcol-custom.service -f
```

## Uninstall

```bash
# Stop/disable
sudo systemctl stop otelcol-custom.service
sudo systemctl disable otelcol-custom.service

# Remove installed files
sudo rm -f /usr/bin/otelcol-custom
sudo rm -f /usr/bin/otelcol-exec-start-pre.sh
sudo rm -rf /etc/otelcol-custom
sudo rm -f /etc/systemd/system/otelcol-custom.service

# Reload systemd
sudo systemctl daemon-reload
```

## Additional resources

- OpenTelemetry Collector docs: [https://opentelemetry.io/docs/collector/](https://opentelemetry.io/docs/collector/)
- See `builder-config.yaml` in this repo for component makeup
- Check `README.md` and `CHANGELOG.md` for version‑specific notes

**Try these if you get stuck:**

1. Re‑run the pre‑start script by hand
2. tail the unit logs
3. validate the YAML
4. verify network and targets, then
5. file an issue with logs, your `otelcol-custom.conf` (scrub secrets), and `config.yaml`.
