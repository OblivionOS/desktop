#!/bin/bash
# Script to run QEMU directly on Linux host (without Docker)

echo "Running Oblivion Desktop QEMU directly on Linux host..."

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Error: This script is designed for Linux hosts only"
    echo "For other systems, use run-qemu-docker.sh"
    exit 1
fi

# Check for QEMU image
if [ -f "debian13-trixie-docker.qcow2" ]; then
    IMAGE_PATH="debian13-trixie-docker.qcow2"
elif [ -f "/qemu-images/debian13-trixie-docker.qcow2" ]; then
    IMAGE_PATH="/qemu-images/debian13-trixie-docker.qcow2"
else
    echo "No QEMU image found. Creating one..."
    echo "Note: This requires root privileges to create the image"
    sudo ./create-qemu-image.sh
    IMAGE_PATH="debian13-trixie-docker.qcow2"
fi

# Verify image exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: QEMU image not found at $IMAGE_PATH"
    exit 1
fi

# Check if KVM is available
if [ -c /dev/kvm ] && [ -w /dev/kvm ]; then
    echo "KVM available, using hardware acceleration"
    KVM_ARGS="-enable-kvm -cpu host"
else
    echo "KVM not available, using software emulation"
    KVM_ARGS="-cpu qemu64"
fi

# Launch QEMU with GUI
echo "Launching QEMU VM with GUI..."
echo "Image: $IMAGE_PATH"
echo "Close the QEMU window to exit"

MEMORY="2G"
CORES="2"

qemu-system-x86_64 \
    $KVM_ARGS \
    -m $MEMORY \
    -smp $CORES \
    -drive file="$IMAGE_PATH",format=qcow2 \
    -net nic,model=virtio \
    -net user,hostfwd=tcp::2222-:22 \
    -vga virtio \
    -display gtk \
    -device virtio-rng-pci \
    -device virtio-balloon \
    -boot c \
    -name "OblivionOS Desktop"

echo "QEMU VM exited."