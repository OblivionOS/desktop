#!/bin/bash
# Script to create a minimal Debian system with OblivionOS pre-installed

set -e

IMAGE_FILE="debian13-trixie-docker.qcow2"
MOUNT_POINT="/tmp/oblivion-chroot"
SIZE="5368709120"  # 5GB exactly

echo "Creating minimal Debian system with OblivionOS..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Install required packages
apt-get update
apt-get install -y debootstrap qemu-utils

# Create qcow2 image if it doesn't exist
if [ ! -f "$IMAGE_FILE" ]; then
    echo "Creating QEMU image..."
    rm -f "$IMAGE_FILE"
    qemu-img create -f qcow2 "$IMAGE_FILE" "$SIZE"
fi

# Set up loop device
LOOP_DEVICE=$(losetup -f)
losetup "$LOOP_DEVICE" "$IMAGE_FILE"

# Create partition table and filesystem
echo "Creating partition table..."
fdisk "$LOOP_DEVICE" << EOF
o
n
p
1


w
EOF

# Wait for partition to be recognized
sleep 2
partprobe "$LOOP_DEVICE"

mkfs.ext4 "${LOOP_DEVICE}p1"

# Mount the filesystem
mkdir -p "$MOUNT_POINT"
mount "${LOOP_DEVICE}p1" "$MOUNT_POINT"

# Bootstrap minimal Debian
echo "Bootstrapping Debian..."
debootstrap --variant=minbase trixie "$MOUNT_POINT" http://deb.debian.org/debian/

# Configure the chroot environment
mount -t proc proc "$MOUNT_POINT/proc"
mount -t sysfs sys "$MOUNT_POINT/sys"
mount --bind /dev "$MOUNT_POINT/dev"
mount --bind /dev/pts "$MOUNT_POINT/dev/pts"
mount -t devpts devpts "$MOUNT_POINT/dev/pts"

# Copy DNS configuration
cp /etc/resolv.conf "$MOUNT_POINT/etc/resolv.conf"

# Configure the system
cat > "$MOUNT_POINT/configure.sh" << 'EOF'
#!/bin/bash
set -e

# Set hostname
echo "oblivion-os" > /etc/hostname

# Configure apt
cat > /etc/apt/sources.list << EOL
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOL

# Update package list
apt-get update

# Install minimal packages
apt-get install -y \
    linux-image-amd64 \
    systemd \
    locales \
    sudo \
    curl \
    vim \
    openssh-server \
    network-manager \
    xorg \
    lightdm \
    xfce4 \
    xfce4-goodies \
    build-essential \
    pkg-config \
    libssl-dev \
    libsdl2-dev \
    libsdl2-ttf-dev \
    libwayland-dev \
    libxkbcommon-dev \
    libegl1-mesa-dev \
    libgles2-mesa-dev

# Configure locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/default/locale

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"

# Create oblivion user
useradd -m -s /bin/bash oblivion
echo "oblivion:oblivion" | chpasswd
usermod -aG sudo oblivion
usermod -aG video oblivion

# Configure sudo
echo "oblivion ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure GRUB
grub-install --target=i386-pc /dev/loop0
update-grub

# Enable services
systemctl enable ssh
systemctl enable lightdm
systemctl enable network-manager

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

chmod +x "$MOUNT_POINT/configure.sh"
chroot "$MOUNT_POINT" /configure.sh

# Copy OblivionOS components (assuming they're built)
if [ -d "/workspace/target/release" ]; then
    cp /workspace/target/release/oblivion-* "$MOUNT_POINT/usr/local/bin/" 2>/dev/null || true
    cp /workspace/oblivion-session.service "$MOUNT_POINT/etc/systemd/system/" 2>/dev/null || true
    cp /workspace/oblivion.desktop "$MOUNT_POINT/usr/share/xsessions/" 2>/dev/null || true
fi

# Clean up chroot
rm "$MOUNT_POINT/configure.sh"
umount "$MOUNT_POINT/dev/pts"
umount "$MOUNT_POINT/dev"
umount "$MOUNT_POINT/sys"
umount "$MOUNT_POINT/proc"
umount "$MOUNT_POINT"

# Clean up loop device
losetup -d "$LOOP_DEVICE"

echo "Minimal Debian system with OblivionOS created: $IMAGE_FILE"
echo "Default login: oblivion/oblivion"