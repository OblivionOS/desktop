#!/bin/bash
# Script to test Linux setup for OblivionOS development

echo "Testing Linux setup for OblivionOS development..."
echo "================================================"

# Check OS
echo "OS: $OSTYPE"
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "⚠️  Warning: This script is designed for Linux systems"
fi

# Check KVM
echo -n "KVM: "
if [ -c /dev/kvm ] && [ -w /dev/kvm ]; then
    echo "✅ Available"
else
    echo "❌ Not available (QEMU will use software emulation)"
fi

# Check QEMU
echo -n "QEMU: "
if command -v qemu-system-x86_64 &> /dev/null; then
    echo "✅ $(qemu-system-x86_64 --version | head -1)"
else
    echo "❌ Not installed"
    echo "   Install with: sudo apt install qemu-system-x86"
fi

# Check Rust
echo -n "Rust: "
if command -v cargo &> /dev/null; then
    echo "✅ $(cargo --version)"
else
    echo "❌ Not installed"
    echo "   Install with: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
fi

# Check SDL2
echo -n "SDL2: "
if pkg-config --exists sdl2 SDL2_ttf; then
    echo "✅ Available"
else
    echo "❌ Not available"
    echo "   Install with: sudo apt install libsdl2-dev libsdl2-ttf-dev"
fi

# Check Wayland
echo -n "Wayland: "
if pkg-config --exists wayland-client wayland-server; then
    echo "✅ Available"
else
    echo "❌ Not available"
    echo "   Install with: sudo apt install libwayland-dev libxkbcommon-dev libegl1-mesa-dev"
fi

# Check Docker
echo -n "Docker: "
if command -v docker &> /dev/null; then
    echo "✅ $(docker --version)"
else
    echo "❌ Not installed (optional for direct QEMU)"
fi

# Check X11
echo -n "X11: "
if [ -n "$DISPLAY" ]; then
    echo "✅ DISPLAY=$DISPLAY"
else
    echo "⚠️  No DISPLAY set (GUI testing may not work)"
fi

# Check QEMU image
echo -n "QEMU Image: "
if [ -f "debian13-trixie-docker.qcow2" ]; then
    echo "✅ Found ($(du -h debian13-trixie-docker.qcow2 | cut -f1))"
elif [ -f "/qemu-images/debian13-trixie-docker.qcow2" ]; then
    echo "✅ Found in /qemu-images ($(du -h /qemu-images/debian13-trixie-docker.qcow2 | cut -f1))"
else
    echo "❌ Not found (run sudo ./create-qemu-image.sh)"
fi

echo ""
echo "Setup test completed!"
echo ""
echo "Next steps:"
echo "1. If anything is missing, install the required packages"
echo "2. Create QEMU image: sudo ./create-qemu-image.sh"
echo "3. Launch VM: ./run-qemu-host.sh (Linux) or ./run-qemu-docker.sh (Docker)"
echo "4. In VM, run: ./setup-vm.sh"