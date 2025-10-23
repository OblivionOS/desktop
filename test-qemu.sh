#!/bin/bash
# Quick QEMU test script to identify specific issues

echo "=== Quick QEMU Test ==="
echo ""

# Test 1: Basic QEMU functionality
echo "Test 1: Basic QEMU functionality"
if command -v qemu-system-x86_64 &> /dev/null; then
    if qemu-system-x86_64 --version &> /dev/null; then
        echo "✓ QEMU binary works"
    else
        echo "✗ QEMU binary exists but failed to run"
        echo "Error output:"
        qemu-system-x86_64 --version 2>&1
        exit 1
    fi
else
    echo "✗ qemu-system-x86_64 command not found"
    echo "Available QEMU commands:"
    ls /usr/bin/qemu* 2>/dev/null || echo "  None found in /usr/bin/"
    echo ""
    echo "Try installing QEMU:"
    echo "  sudo apt-get install qemu-system-x86-64"
    exit 1
fi

echo ""

# Test 2: Try to run QEMU with minimal options
echo "Test 2: Minimal QEMU run (will fail but shows capabilities)"
timeout 5 qemu-system-x86_64 -version 2>&1 | head -10
echo ""

# Test 3: Check for common QEMU options
echo "Test 3: Testing QEMU help for key options"
if qemu-system-x86_64 --help | grep -q "enable-kvm"; then
    echo "✓ KVM support available"
else
    echo "! KVM support not detected"
fi

if qemu-system-x86_64 --help | grep -q "display"; then
    echo "✓ Display options available"
else
    echo "! Display options not available"
fi

echo ""

# Test 4: Check image if it exists
echo "Test 4: Image check"
if [ -f "debian13-trixie-docker.qcow2" ]; then
    echo "✓ Image file exists"
    if qemu-img check "debian13-trixie-docker.qcow2" &> /dev/null; then
        echo "✓ Image file is valid"
    else
        echo "✗ Image file is corrupted"
        qemu-img check "debian13-trixie-docker.qcow2"
    fi
else
    echo "! No image file found"
fi

echo ""

# Test 5: Try actual launch with current configuration
echo "Test 5: Attempting actual launch (will timeout after 10 seconds)"
echo "This will show the exact error you encountered..."

IMAGE_FILE="debian13-trixie-docker.qcow2"
if [ -f "$IMAGE_FILE" ]; then
    echo "Launching with: qemu-system-x86_64 -hda $IMAGE_FILE -m 1G -smp 1 -nographic"
    timeout 10 qemu-system-x86_64 -hda "$IMAGE_FILE" -m 1G -smp 1 -nographic 2>&1 || true
else
    echo "No image available for testing"
fi

echo ""
echo "=== Test Complete ==="
echo ""
echo "If you see specific errors above, check the troubleshooting section"
echo "or run: ./diagnose-qemu.sh"