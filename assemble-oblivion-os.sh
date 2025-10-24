#!/bin/bash
# Script to assemble complete OblivionOS image

set -e

echo "🚀 Assembling OblivionOS - Pure Linux Environment"
echo "================================================"

# Build components statically
echo "🔨 Building static components..."
./build-static-components.sh

# Create root filesystem
echo "📁 Creating root filesystem..."
./create-oblivion-rootfs.sh

# Install components
echo "📦 Installing components..."
docker run --rm -v $(pwd):/workspace oblivion-desktop /bin/bash -c "
cp /workspace/target/release/oblivion-session /workspace/oblivion-rootfs/usr/local/bin/ 2>/dev/null || true
cp /workspace/target/release/oblivion-comp /workspace/oblivion-rootfs/usr/local/bin/ 2>/dev/null || true
"

# Create initramfs
echo "📦 Creating initramfs..."
docker run --rm -v $(pwd):/workspace oblivion-desktop /bin/bash -c "
cd /workspace/oblivion-rootfs
find . | cpio -H newc -o | gzip > ../oblivion-initramfs.img
"

# Build kernel from submodule
echo "🌱 Building kernel from submodule..."
if [ ! -f "oblivion-kernel" ]; then
    if [ -d "kernel" ] && [ -f "kernel/Makefile" ]; then
        echo "Building kernel from submodule..."
        cd kernel
        # Use existing config or make defconfig
        if [ -f ".config" ]; then
            echo "Using existing kernel config"
        else
            make defconfig
        fi
        make -j$(nproc) bzImage
        cp arch/x86/boot/bzImage ../oblivion-kernel
        cd ..
        echo "Kernel built from submodule"
    else
        echo "⚠️ Kernel submodule not available, using system kernel"
        cp /boot/vmlinuz-* oblivion-kernel 2>/dev/null || echo "No system kernel found"
    fi
fi

# Create QEMU disk image
echo "💾 Creating QEMU disk image..."
qemu-img create -f qcow2 oblivion-os.img 1G

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