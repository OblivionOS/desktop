#!/bin/bash
# Script to run OblivionOS with custom kernel and initramfs

set -e

echo "🚀 Launching OblivionOS"

# Check if files exist
if [ ! -f "oblivion-kernel" ]; then
    echo "❌ oblivion-kernel not found. Run ./assemble-oblivion-os.sh first"
    exit 1
fi

if [ ! -f "oblivion-initramfs.img" ]; then
    echo "❌ oblivion-initramfs.img not found. Run ./assemble-oblivion-os.sh first"
    exit 1
fi

# QEMU arguments
KERNEL_ARGS=(
    -kernel oblivion-kernel
    -initrd oblivion-initramfs.img
    -append "console=ttyS0 init=/init quiet"
    -m 512M
    -smp 1
    -no-reboot
    -monitor none
)

# Check if we have display
if [ -n "$DISPLAY" ]; then
    echo "🎨 Graphical mode detected"
    QEMU_ARGS+=(
        -vga virtio
        -display gtk
        -device virtio-rng-pci
    )
else
    echo "📟 Text mode (no display detected)"
    QEMU_ARGS+=(
        -nographic
        -serial stdio
    )
fi

# Add KVM if available
if [ -c /dev/kvm ] && [ -w /dev/kvm ]; then
    echo "⚡ KVM acceleration available"
    QEMU_ARGS+=(-enable-kvm -cpu host)
else
    echo "🐌 Software emulation (KVM not available)"
    QEMU_ARGS+=(-cpu qemu64)
fi

echo "Starting QEMU with OblivionOS..."
echo "Kernel: oblivion-kernel"
echo "Initramfs: oblivion-initramfs.img"
echo "Press Ctrl+A, X to exit"
echo ""

# Launch QEMU
qemu-system-x86_64 "${QEMU_ARGS[@]}"

echo ""
echo "OblivionOS session ended."