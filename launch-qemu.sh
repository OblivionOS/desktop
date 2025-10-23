#!/bin/bash
# Script to launch QEMU VM with Debian 13 and Docker for Oblivion Desktop testing

IMAGE_FILE="debian13-trixie-docker.qcow2"
MEMORY="4G"
CPUS="2"

# Check if running in Docker container
if [ -f "/.dockerenv" ]; then
    # Running in Docker - use SDL display
    DISPLAY_OPTS="-display sdl"
    KVM_OPTS=""
    echo "Running in Docker container - using SDL display"
else
    # Running on host - try KVM and VNC
    KVM_OPTS="-enable-kvm"
    DISPLAY_OPTS="-vnc :0"
    DISPLAY_PORT="5900"
    WEB_PORT="6080"
    echo "Launching QEMU VM for Oblivion Desktop testing..."
    echo "VNC will be available on localhost:$DISPLAY_PORT"
    echo "Web VNC will be available on localhost:$WEB_PORT"
    echo ""
    echo "To connect:"
    echo "  VNC: vncviewer localhost:$DISPLAY_PORT"
    echo "  Web: Open http://localhost:$WEB_PORT in your browser"
    echo ""
fi

# Check if image exists
if [ ! -f "$IMAGE_FILE" ]; then
    echo "QEMU image not found. Run create-qemu-image.sh first."
    exit 1
fi

echo "Default login: developer / developer"
echo ""

# Launch QEMU
qemu-system-x86_64 \
    $KVM_OPTS \
    -m "$MEMORY" \
    -smp "$CPUS" \
    -drive file="$IMAGE_FILE",format=qcow2 \
    -net nic,model=virtio \
    -net user,hostfwd=tcp::2222-:22 \
    $DISPLAY_OPTS \
    -vga virtio \
    -device virtio-rng-pci \
    -boot c \
    -name "Oblivion Desktop VM"