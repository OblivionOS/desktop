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

# Download/build kernel (simplified - using prebuilt for now)
echo "🌱 Setting up kernel..."
if [ ! -f "oblivion-kernel" ]; then
    # For now, use a simple kernel download
    # In production, we'd build our own minimal kernel
    echo "⚠️ Using generic kernel - customize for production"
    # Copy from system or download
    cp /boot/vmlinuz-* oblivion-kernel 2>/dev/null || \
    wget -O oblivion-kernel "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.0.tar.xz" && \
    tar -xf linux-6.1.0.tar.xz && \
    cd linux-6.1.0 && \
    make defconfig && \
    make -j$(nproc) bzImage && \
    cp arch/x86/boot/bzImage ../oblivion-kernel && \
    cd .. && \
    rm -rf linux-6.1.0*
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