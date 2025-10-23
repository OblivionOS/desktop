#!/bin/bash
# Script to create a Debian 13 (Trixie) QEMU image with Docker pre-installed

set -e

IMAGE_SIZE="10G"
IMAGE_FILE="debian13-trixie-docker.qcow2"
MOUNT_POINT="/tmp/debian-chroot"

echo "Creating Debian 13 Trixie QEMU image with Docker..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Install required packages
apt-get update
apt-get install -y debootstrap qemu-utils

# Create empty qcow2 image
qemu-img create -f qcow2 "$IMAGE_FILE" "$IMAGE_SIZE"

# Set up loop device and format
LOOP_DEVICE=$(losetup -f)
losetup "$LOOP_DEVICE" "$IMAGE_FILE"

# Create partition table and filesystem
parted -s "$LOOP_DEVICE" mklabel msdos
parted -s "$LOOP_DEVICE" mkpart primary ext4 1MiB 100%
mkfs.ext4 "${LOOP_DEVICE}p1"

# Mount the filesystem
mkdir -p "$MOUNT_POINT"
mount "${LOOP_DEVICE}p1" "$MOUNT_POINT"

# Bootstrap Debian 13 Trixie
debootstrap --arch=amd64 trixie "$MOUNT_POINT" http://deb.debian.org/debian/

# Configure the chroot environment
mount -t proc proc "$MOUNT_POINT/proc"
mount -t sysfs sys "$MOUNT_POINT/sys"
mount --bind /dev "$MOUNT_POINT/dev"
mount --bind /dev/pts "$MOUNT_POINT/dev/pts"
mount -t devpts devpts "$MOUNT_POINT/dev/pts"

# Copy DNS configuration
cp /etc/resolv.conf "$MOUNT_POINT/etc/resolv.conf"

# Chroot and configure the system
cat > "$MOUNT_POINT/configure.sh" << 'EOF'
#!/bin/bash
set -e

# Set hostname
echo "oblivion-desktop-vm" > /etc/hostname

# Configure apt sources
cat > /etc/apt/sources.list << EOL
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOL

# Update package list
apt-get update

# Install basic packages
apt-get install -y \
    linux-image-amd64 \
    grub-pc \
    systemd \
    locales \
    sudo \
    curl \
    wget \
    vim \
    openssh-server \
    network-manager \
    xorg \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    novnc \
    websockify

# Configure locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/default/locale

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker developer

# Create developer user
useradd -m -s /bin/bash developer
echo "developer:developer" | chpasswd
usermod -aG sudo developer
usermod -aG docker developer

# Configure sudo
echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Rust and SDL2 dependencies
su - developer -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    libsdl2-dev \
    libsdl2-ttf-dev \
    git

# Configure GRUB
grub-install --target=i386-pc "$LOOP_DEVICE"
update-grub

# Enable services
systemctl enable ssh
systemctl enable docker

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

chmod +x "$MOUNT_POINT/configure.sh"
chroot "$MOUNT_POINT" /configure.sh

# Clean up chroot
rm "$MOUNT_POINT/configure.sh"
umount "$MOUNT_POINT/dev/pts"
umount "$MOUNT_POINT/dev"
umount "$MOUNT_POINT/sys"
umount "$MOUNT_POINT/proc"
umount "$MOUNT_POINT"

# Clean up loop device
losetup -d "$LOOP_DEVICE"

echo "Debian 13 Trixie QEMU image created: $IMAGE_FILE"
echo "Default login: developer/developer"