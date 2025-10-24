#!/bin/bash
# Script to create minimal root filesystem for OblivionOS

set -e

ROOTFS_DIR="oblivion-rootfs"
MIRROR="http://deb.debian.org/debian"

echo "📁 Creating minimal OblivionOS root filesystem..."

# Clean up
rm -rf "$ROOTFS_DIR"

# Create minimal Debian system
echo "📦 Bootstrapping minimal Debian..."
debootstrap --variant=minbase --include=busybox,libc6,libgcc-s1,libstdc++6,zlib1g,ca-certificates \
    --foreign trixie "$ROOTFS_DIR" "$MIRROR"

# Complete the bootstrap
echo "🔧 Completing bootstrap..."
chroot "$ROOTFS_DIR" /bin/sh -c "
/debootstrap/debootstrap --second-stage
apt-get clean
rm -rf /var/lib/apt/lists/*
"

# Configure basic system
echo "⚙️ Configuring system..."
cat > "$ROOTFS_DIR"/etc/hostname << EOF
oblivion-os
EOF

cat > "$ROOTFS_DIR"/etc/fstab << EOF
proc /proc proc defaults 0 0
sysfs /sys sysfs defaults 0 0
devpts /dev/pts devpts defaults 0 0
tmpfs /tmp tmpfs defaults 0 0
EOF

cat > "$ROOTFS_DIR"/etc/passwd << EOF
root:x:0:0:root:/root:/bin/sh
oblivion:x:1000:1000:oblivion:/home/oblivion:/bin/sh
EOF

cat > "$ROOTFS_DIR"/etc/group << EOF
root:x:0:
oblivion:x:1000:
EOF

# Create init script
cat > "$ROOTFS_DIR"/init << 'EOF'
#!/bin/sh
echo "OblivionOS Starting..."
echo "Mounting filesystems..."

# Mount filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devpts devpts /dev/pts

echo "Filesystems mounted."
echo "Setting up environment..."

# Basic setup
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
export HOME=/root

# Create runtime directories
mkdir -p /var/log /var/run /tmp

# Start OblivionOS
echo "Launching OblivionOS..."
exec /usr/local/bin/oblivion-session
EOF

chmod +x "$ROOTFS_DIR"/init

# Install essential libraries for Rust
echo "📚 Installing Rust dependencies..."
chroot "$ROOTFS_DIR" /bin/sh -c "
apt-get update
apt-get install -y --no-install-recommends \
    libgcc-s1 \
    libstdc++6 \
    zlib1g \
    ca-certificates
apt-get clean
"

# Install kernel headers from the submodule
echo "🌱 Installing kernel headers from submodule..."
if [ -d "./kernel" ]; then
    mkdir -p "$ROOTFS_DIR/usr/src/linux-headers"
    cp -r ./kernel/include "$ROOTFS_DIR/usr/src/linux-headers/" 2>/dev/null || true
    cp ./kernel/.config "$ROOTFS_DIR/usr/src/linux-headers/.config" 2>/dev/null || true
    cp ./kernel/Makefile "$ROOTFS_DIR/usr/src/linux-headers/Makefile" 2>/dev/null || true
    echo "Kernel headers installed from submodule at /usr/src/linux-headers"
else
    echo "Warning: kernel submodule not found, installing generic headers"
    chroot "$ROOTFS_DIR" /bin/sh -c "
    apt-get update
    apt-get install -y --no-install-recommends linux-headers-amd64
    apt-get clean
    "
fi

# Create directories
mkdir -p "$ROOTFS_DIR"/usr/local/bin
mkdir -p "$ROOTFS_DIR"/home/oblivion
mkdir -p "$ROOTFS_DIR"/var/log

echo "✅ Root filesystem created in $ROOTFS_DIR"