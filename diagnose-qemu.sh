#!/bin/bash
# Diagnostic script for QEMU issues in Oblivion Desktop

echo "=== QEMU Diagnostic Tool ==="
echo ""

# Check if running in Docker
if [ -f "/.dockerenv" ]; then
    echo "✓ Running inside Docker container"
else
    echo "✗ Running on host system (not in Docker)"
fi

echo ""

# Check QEMU installation
echo "Checking QEMU installation..."
if command -v qemu-system-x86_64 &> /dev/null; then
    echo "✓ qemu-system-x86_64 found: $(qemu-system-x86_64 --version | head -1)"
else
    echo "✗ qemu-system-x86_64 not found"
    echo "  Available QEMU commands:"
    ls /usr/bin/qemu* 2>/dev/null || echo "    No QEMU commands found"
fi

if command -v qemu-img &> /dev/null; then
    echo "✓ qemu-img found: $(qemu-img --version | head -1)"
else
    echo "✗ qemu-img not found"
fi

# Check if we're in a container that needs rebuild
if [ -f "/.dockerenv" ]; then
    echo ""
    echo "Container information:"
    echo "  Image needs QEMU packages: qemu-system-x86 qemu-system-x86-64 qemu-utils"
    echo "  If missing, rebuild with: docker build --no-cache -t oblivion-desktop ."
fi

echo ""

# Check KVM access
echo "Checking KVM access..."
if [ -c "/dev/kvm" ]; then
    if [ -r "/dev/kvm" ] && [ -w "/dev/kvm" ]; then
        echo "✓ KVM device accessible (/dev/kvm)"
    else
        echo "✗ KVM device not accessible (permissions issue)"
        echo "  Try running Docker with --privileged flag"
    fi
else
    echo "! KVM device not present (using emulation mode)"
    echo "  This will be slower but should still work"
fi

echo ""

# Check display
echo "Checking display configuration..."
if [ -n "$DISPLAY" ]; then
    echo "✓ DISPLAY set to: $DISPLAY"
else
    echo "✗ DISPLAY not set"
    echo "  For GUI, set: export DISPLAY=:0"
fi

if [ -d "/tmp/.X11-unix" ]; then
    echo "✓ X11 socket directory exists"
else
    echo "✗ X11 socket directory missing"
fi

echo ""

# Check image
echo "Checking QEMU image..."
if [ -f "debian13-trixie-docker.qcow2" ]; then
    echo "✓ Local image found: debian13-trixie-docker.qcow2"
    echo "  Size: $(ls -lh debian13-trixie-docker.qcow2 | awk '{print $5}')"
elif [ -f "/qemu-images/debian13-trixie-docker.qcow2" ]; then
    echo "✓ Mounted image found: /qemu-images/debian13-trixie-docker.qcow2"
    echo "  Size: $(ls -lh /qemu-images/debian13-trixie-docker.qcow2 | awk '{print $5}')"
else
    echo "✗ No QEMU image found"
    echo "  Run: sudo ./create-qemu-image.sh"
fi

echo ""

# Check memory
echo "Checking memory..."
TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_MEM_GB=$((TOTAL_MEM / 1024 / 1024))

if [ $TOTAL_MEM_GB -ge 8 ]; then
    echo "✓ Sufficient memory: ${TOTAL_MEM_GB}GB"
else
    echo "! Limited memory: ${TOTAL_MEM_GB}GB (recommended: 8GB+)"
fi

echo ""

# Test QEMU basic functionality
echo "Testing QEMU basic functionality..."
if qemu-system-x86_64 --version &> /dev/null; then
    echo "✓ QEMU basic test passed"
else
    echo "✗ QEMU basic test failed"
fi

echo ""

# Recommendations
echo "=== Recommendations ==="
echo ""

if [ ! -f "debian13-trixie-docker.qcow2" ] && [ ! -f "/qemu-images/debian13-trixie-docker.qcow2" ]; then
    echo "1. Create a QEMU image first:"
    echo "   sudo ./create-qemu-image.sh"
    echo ""
fi

if [ ! -c "/dev/kvm" ] || ([ -c "/dev/kvm" ] && [ ! -r "/dev/kvm" ]); then
    echo "2. For better performance, ensure KVM access:"
    echo "   - On host: sudo chmod 666 /dev/kvm"
    echo "   - In Docker: use --privileged flag"
    echo ""
fi

if [ -z "$DISPLAY" ]; then
    echo "3. For GUI display, set DISPLAY:"
    echo "   export DISPLAY=:0"
    echo ""
fi

echo "4. Try running with different options:"
echo "   ./run-qemu-docker.sh          # Creates new image in container"
echo "   ./run-qemu-with-image.sh ./debian13-trixie-docker.qcow2  # Uses existing image"
echo ""

echo "5. If issues persist, try running QEMU directly:"
echo "   qemu-system-x86_64 -hda debian13-trixie-docker.qcow2 -m 2G -smp 1 -vga std"
echo ""

echo "=== End Diagnostic ==="