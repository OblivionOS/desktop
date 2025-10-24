#!/bin/bash
# Script to assemble complete OblivionOS image

set -e

echo "🚀 Assembling OblivionOS - Pure Linux Environment"
echo "================================================"

# Check prerequisites
echo "🔍 Checking prerequisites..."
command -v cpio >/dev/null 2>&1 || { echo "cpio not found, install it with: sudo apt install cpio"; exit 1; }
command -v gzip >/dev/null 2>&1 || { echo "gzip not found, install it with: sudo apt install gzip"; exit 1; }
command -v qemu-img >/dev/null 2>&1 || { echo "qemu-img not found, install qemu-utils with: sudo apt install qemu-utils"; exit 1; }
command -v flex >/dev/null 2>&1 || { echo "flex not found, install flex with: sudo apt install flex"; exit 1; }
command -v bison >/dev/null 2>&1 || { echo "bison not found, install bison with: sudo apt install bison"; exit 1; }

# Build components statically
echo "🔨 Building static components..."
# Regenerate lock file if needed
rm -f Cargo.lock
./build-static-components.sh

# Create root filesystem
echo "📁 Creating root filesystem..."
./create-oblivion-rootfs.sh

# Install components
echo "📦 Installing components..."
if [ -d "oblivion-rootfs" ]; then
    cp target/release/oblivion-session oblivion-rootfs/usr/local/bin/ 2>/dev/null || echo "oblivion-session not found"
    cp target/release/oblivion-comp oblivion-rootfs/usr/local/bin/ 2>/dev/null || echo "oblivion-comp not found"
else
    echo "oblivion-rootfs not found, run create-oblivion-rootfs.sh first"
    exit 1
fi

# Create initramfs
echo "📦 Creating initramfs..."
if [ -d "oblivion-rootfs" ]; then
    cd oblivion-rootfs
    find . | cpio -H newc -o | gzip > ../oblivion-initramfs.img
    cd ..
else
    echo "oblivion-rootfs not found"
    exit 1
fi

# Build kernel from submodule
echo "🌱 Building kernel from submodule..."
if [ ! -f "oblivion-kernel" ]; then
    if [ -d "kernel" ] && [ -f "kernel/Makefile" ]; then
        echo "Building kernel from submodule..."
        cd kernel
        # Check if make is available
        command -v make >/dev/null 2>&1 || { echo "make not found"; exit 1; }
        # Use existing config or make defconfig
        if [ -f ".config" ]; then
            echo "Using existing kernel config"
        else
            echo "Creating default kernel config..."
            make defconfig
        fi
        echo "Building kernel image..."
        make -j$(nproc) bzImage
        if [ -f "arch/x86/boot/bzImage" ]; then
            cp arch/x86/boot/bzImage ../oblivion-kernel
            cd ..
            echo "Kernel built successfully"
        else
            cd ..
            echo "Kernel build failed, no bzImage found"
            exit 1
        fi
    else
        echo "⚠️ Kernel submodule not available, trying system kernel"
        if [ -f "/boot/vmlinuz-$(uname -r)" ]; then
            cp /boot/vmlinuz-$(uname -r) oblivion-kernel
            echo "Using system kernel"
        else
            echo "No kernel found"
            exit 1
        fi
    fi
fi

# Create QEMU disk image
echo "💾 Creating QEMU disk image..."
qemu-img create -f qcow2 oblivion-os.img 1G || { echo "Failed to create QEMU image"; exit 1; }

# Verify files
echo "🔍 Verifying assembly..."
[ -f "oblivion-kernel" ] || { echo "oblivion-kernel not found"; exit 1; }
[ -f "oblivion-initramfs.img" ] || { echo "oblivion-initramfs.img not found"; exit 1; }
[ -f "oblivion-os.img" ] || { echo "oblivion-os.img not found"; exit 1; }

echo "✅ OblivionOS assembly complete!"
echo ""
echo "Files created:"
echo "- oblivion-kernel: Linux kernel"
echo "- oblivion-initramfs.img: Root filesystem with OblivionOS"
echo "- oblivion-os.img: QEMU disk image"
echo ""
echo "To run OblivionOS:"
echo "qemu-system-x86_64 \\"
echo "  -kernel oblivion-kernel \\"
echo "  -initrd oblivion-initramfs.img \\"
echo "  -append 'console=ttyS0 init=/init' \\"
echo "  -nographic"
echo ""
echo "For graphical mode:"
echo "qemu-system-x86_64 \\"
echo "  -kernel oblivion-kernel \\"
echo "  -initrd oblivion-initramfs.img \\"
echo "  -append 'init=/init' \\"
echo "  -vga virtio"
echo ""
echo "For graphical mode:"
echo "qemu-system-x86_64 \\"
echo "  -kernel oblivion-kernel \\"
echo "  -initrd oblivion-initramfs.img \\"
echo "  -append 'init=/init' \\"
echo "  -vga virtio"