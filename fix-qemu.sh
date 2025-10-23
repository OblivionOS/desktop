#!/bin/bash
# Script to fix QEMU installation issues

echo "=== QEMU Fix Script ==="
echo ""

# Check if running in Docker
if [ -f "/.dockerenv" ]; then
    echo "Running in Docker container"
    echo "Installing QEMU packages..."

    # Update package list
    apt-get update

    # Install QEMU packages
    apt-get install -y qemu-system-x86 qemu-system-x86-64 qemu-utils

    # Verify installation
    if command -v qemu-system-x86_64 &> /dev/null; then
        echo "✓ QEMU installed successfully"
        qemu-system-x86_64 --version | head -1
    else
        echo "✗ QEMU installation failed"
        exit 1
    fi

    echo ""
    echo "You can now run QEMU commands"
    echo "Example: ./launch-qemu.sh"

elif [[ $EUID -eq 0 ]]; then
    echo "Running as root on host system"
    echo "Installing QEMU packages..."

    # Try different package managers
    if command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y qemu qemu-kvm qemu-system-x86
    elif command -v yum &> /dev/null; then
        yum install -y qemu qemu-kvm qemu-system-x86
    elif command -v dnf &> /dev/null; then
        dnf install -y qemu qemu-kvm qemu-system-x86
    elif command -v pacman &> /dev/null; then
        pacman -S qemu --noconfirm
    else
        echo "Unsupported package manager"
        exit 1
    fi

    # Verify installation
    if command -v qemu-system-x86_64 &> /dev/null; then
        echo "✓ QEMU installed successfully"
        qemu-system-x86_64 --version | head -1
    else
        echo "✗ QEMU installation failed"
        exit 1
    fi

else
    echo "Not running as root and not in Docker"
    echo "Please run as root or in Docker container"
    echo ""
    echo "For Docker: docker run -it --rm oblivion-desktop ./fix-qemu.sh"
    echo "For host: sudo ./fix-qemu.sh"
    exit 1
fi

echo ""
echo "=== Fix Complete ==="