#!/bin/bash
# Script to build OblivionOS from scratch with only Linux kernel import

set -e

echo "🚀 Building OblivionOS - Pure Linux Environment"
echo "=============================================="

# Configuration
IMAGE_SIZE="2G"
ROOTFS_DIR="oblivion-rootfs"
KERNEL_VERSION="6.1.0"
BUSYBOX_VERSION="1.36.1"

# Clean up previous builds
echo "🧹 Cleaning up previous builds..."
rm -rf "$ROOTFS_DIR"
rm -f oblivion-kernel oblivion-initramfs.img oblivion-os.img

# Create root filesystem directory
echo "📁 Creating root filesystem..."
mkdir -p "$ROOTFS_DIR"
mkdir -p "$ROOTFS_DIR"/{bin,sbin,etc,proc,sys,dev,tmp,var,usr/{bin,lib},lib64}
mkdir -p "$ROOTFS_DIR"/usr/local/bin

# Install essential directories
mkdir -p "$ROOTFS_DIR"/etc/init.d
mkdir -p "$ROOTFS_DIR"/usr/share/fonts
mkdir -p "$ROOTFS_DIR"/usr/share/terminfo

echo "📦 Installing essential files..."

# Create basic device nodes
mknod -m 622 "$ROOTFS_DIR"/dev/console c 5 1
mknod -m 666 "$ROOTFS_DIR"/dev/null c 1 3
mknod -m 666 "$ROOTFS_DIR"/dev/zero c 1 5
mknod -m 666 "$ROOTFS_DIR"/dev/ptmx c 5 2
mknod -m 666 "$ROOTFS_DIR"/dev/tty c 5 0
mknod -m 444 "$ROOTFS_DIR"/dev/random c 1 8
mknod -m 444 "$ROOTFS_DIR"/dev/urandom c 1 9
mknod -m 666 "$ROOTFS_DIR"/dev/tty0 c 4 0
mknod -m 666 "$ROOTFS_DIR"/dev/tty1 c 4 1

# Create basic configuration files
cat > "$ROOTFS_DIR"/etc/passwd << EOF
root:x:0:0:root:/root:/bin/sh
oblivion:x:1000:1000:oblivion:/home/oblivion:/bin/sh
EOF

cat > "$ROOTFS_DIR"/etc/group << EOF
root:x:0:
oblivion:x:1000:
EOF

cat > "$ROOTFS_DIR"/etc/hostname << EOF
oblivion-os
EOF

cat > "$ROOTFS_DIR"/etc/fstab << EOF
proc /proc proc defaults 0 0
sysfs /sys sysfs defaults 0 0
devpts /dev/pts devpts defaults 0 0
tmpfs /tmp tmpfs defaults 0 0
EOF

# Download and install BusyBox for minimal utilities
echo "📥 Downloading BusyBox..."
if [ ! -f "busybox-$BUSYBOX_VERSION.tar.bz2" ]; then
    wget "https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2"
fi

echo "🔨 Building BusyBox..."
tar -xf "busybox-$BUSYBOX_VERSION.tar.bz2"
cd "busybox-$BUSYBOX_VERSION"

make defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
make -j$(nproc)
make install

cp -r _install/* "../$ROOTFS_DIR/"
cd ..
rm -rf "busybox-$BUSYBOX_VERSION"

# Install essential libraries for Rust programs
echo "📚 Installing essential libraries..."

# Copy system libraries (assuming we're on a compatible system)
cp /lib64/ld-linux-x86-64.so.2 "$ROOTFS_DIR"/lib64/ 2>/dev/null || true
cp /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 "$ROOTFS_DIR"/lib64/ 2>/dev/null || true

# Essential libraries for SDL2 and Rust
ESSENTIAL_LIBS=(
    libSDL2-2.0.so.0
    libSDL2_ttf-2.0.so.0
    libfreetype.so.6
    libpng16.so.16
    libz.so.1
    libbz2.so.1.0
    libgcc_s.so.1
    libstdc++.so.6
    libc.so.6
    libm.so.6
    libdl.so.2
    libpthread.so.0
    librt.so.1
    libutil.so.1
)

for lib in "${ESSENTIAL_LIBS[@]}"; do
    find /lib /lib64 /usr/lib /usr/lib64 -name "$lib" -exec cp {} "$ROOTFS_DIR"/lib64/ \; 2>/dev/null || true
done

# Build and install OblivionOS components
echo "🔨 Building OblivionOS components..."
cargo build --release --workspace

# Copy components to rootfs
cp target/release/oblivion-session "$ROOTFS_DIR"/usr/local/bin/
cp target/release/oblivion-comp "$ROOTFS_DIR"/usr/local/bin/
cp target/release/oblivion-shell "$ROOTFS_DIR"/usr/local/bin/
cp target/release/oblivion-panel "$ROOTFS_DIR"/usr/local/bin/

# Create init script
cat > "$ROOTFS_DIR"/init << 'EOF'
#!/bin/sh
echo "OblivionOS Init Starting..."

# Mount essential filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devpts devpts /dev/pts

# Set up environment
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
export HOME=/root
export USER=root

# Start udev for device management
if [ -x /sbin/udevd ]; then
    /sbin/udevd --daemon
    udevadm trigger
    udevadm settle
fi

# Set up basic networking (optional)
ifconfig lo up 2>/dev/null || true

echo "Starting OblivionOS Session Manager..."
exec /usr/local/bin/oblivion-session
EOF

chmod +x "$ROOTFS_DIR"/init

# Create initramfs
echo "📦 Creating initramfs..."
cd "$ROOTFS_DIR"
find . | cpio -H newc -o | gzip > ../oblivion-initramfs.img
cd ..

# Download Linux kernel
echo "🌱 Downloading Linux kernel..."
if [ ! -f "linux-$KERNEL_VERSION.tar.xz" ]; then
    wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz"
fi

echo "🔨 Building Linux kernel..."
tar -xf "linux-$KERNEL_VERSION.tar.xz"
cd "linux-$KERNEL_VERSION"

# Configure minimal kernel
make defconfig
# Enable essential options for our use case
cat >> .config << EOF
CONFIG_BLK_DEV_INITRD=y
CONFIG_RD_GZIP=y
CONFIG_BINFMT_ELF=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_PROC_FS=y
CONFIG_SYSFS=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_TMPFS=y
CONFIG_DRM=y
CONFIG_DRM_VIRTIO_GPU=y
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_SQUASHFS=y
CONFIG_OVERLAY_FS=y
EOF

make -j$(nproc)
cp arch/x86/boot/bzImage ../oblivion-kernel
cd ..
rm -rf "linux-$KERNEL_VERSION"

# Create final QEMU image
echo "💾 Creating final QEMU image..."
qemu-img create -f qcow2 oblivion-os.img "$IMAGE_SIZE"

echo "✅ OblivionOS build complete!"
echo ""
echo "Files created:"
echo "- oblivion-kernel: Linux kernel"
echo "- oblivion-initramfs.img: Initial ramdisk with OblivionOS"
echo "- oblivion-os.img: QEMU disk image"
echo ""
echo "To run OblivionOS:"
echo "qemu-system-x86_64 -kernel oblivion-kernel -initrd oblivion-initramfs.img -append 'console=ttyS0' -nographic"