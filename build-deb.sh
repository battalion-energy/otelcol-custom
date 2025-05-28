#!/bin/bash
set -e

# Script to build Debian package for otelcol-custom
# Usage: ./build-deb.sh <binary-name> <architecture>
# Example: ./build-deb.sh otelcol-custom-linux-amd64 amd64

if [ $# -ne 2 ]; then
    echo "Usage: $0 <binary-name> <architecture>"
    echo "Example: $0 otelcol-custom-linux-amd64 amd64"
    exit 1
fi

BINARY_NAME="$1"
ARCH="$2"
VERSION="1.0.0"

# Create package directory structure
PKG_DIR="otelcol-custom_${VERSION}_${ARCH}"
echo "Creating package directory: ${PKG_DIR}"

mkdir -p ${PKG_DIR}/DEBIAN
mkdir -p ${PKG_DIR}/usr/bin
mkdir -p ${PKG_DIR}/etc/otelcol-custom
mkdir -p ${PKG_DIR}/etc/systemd/system

# Copy binary
echo "Copying binary: ${BINARY_NAME}"
cp ${BINARY_NAME} ${PKG_DIR}/usr/bin/otelcol-custom
chmod +x ${PKG_DIR}/usr/bin/otelcol-custom

# Copy service files
echo "Copying service files"
cp otelcol-custom.service ${PKG_DIR}/etc/systemd/system/
cp otelcol-custom.conf ${PKG_DIR}/etc/otelcol-custom/
cp otelcol-exec-start-pre.sh ${PKG_DIR}/usr/bin/
chmod +x ${PKG_DIR}/usr/bin/otelcol-exec-start-pre.sh

# Copy config
cp config.yaml ${PKG_DIR}/etc/otelcol-custom/

# Create control file
echo "Creating control file"
cat > ${PKG_DIR}/DEBIAN/control << EOF
Package: otelcol-custom
Version: ${VERSION}
Section: net
Priority: optional
Architecture: ${ARCH}
Maintainer: OpenTelemetry <noreply@opentelemetry.io>
Description: Custom OpenTelemetry Collector
 A custom build of the OpenTelemetry Collector with specific components.
EOF

# Create postinst script to enable and start service
echo "Creating postinst script"
cat > ${PKG_DIR}/DEBIAN/postinst << 'EOF'
#!/bin/bash
set -e

if [ "$1" = "configure" ]; then
    # Reload systemd daemon
    systemctl daemon-reload
    
    # Enable service
    systemctl enable otelcol-custom.service
    
    # Start service if not already running
    if ! systemctl is-active --quiet otelcol-custom.service; then
        systemctl start otelcol-custom.service
    fi
fi

exit 0
EOF
chmod +x ${PKG_DIR}/DEBIAN/postinst

# Create prerm script to stop service before removal
echo "Creating prerm script"
cat > ${PKG_DIR}/DEBIAN/prerm << 'EOF'
#!/bin/bash
set -e

if [ "$1" = "remove" ]; then
    # Stop service
    if systemctl is-active --quiet otelcol-custom.service; then
        systemctl stop otelcol-custom.service
    fi
    
    # Disable service
    systemctl disable otelcol-custom.service
fi

exit 0
EOF
chmod +x ${PKG_DIR}/DEBIAN/prerm

# Build the package
echo "Building Debian package"
dpkg-deb --build ${PKG_DIR}

# Create checksum
echo "Creating checksum"
sha256sum ${PKG_DIR}.deb > ${PKG_DIR}.deb.sha256

echo "Package created: ${PKG_DIR}.deb"
echo "Checksum created: ${PKG_DIR}.deb.sha256"