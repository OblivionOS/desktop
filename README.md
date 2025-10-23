# desktop
The OblivionOS Desktop Version

## Setup

This repository provides a minimal Debian 13 (Trixie) base for developing the OblivionOS desktop interface using Rust and the Oblivion SDK (SwiftUI-like framework).

### Building the Docker Image

```bash
# Build the Docker image
docker build -t oblivion-desktop .

# If you encounter QEMU issues, rebuild without cache
docker build --no-cache -t oblivion-desktop .
```

### Running the Development Environment

#### Direct Docker (requires X11)
```bash
docker run -it --rm -v $(pwd):/workspace \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  oblivion-desktop
```

#### QEMU VM Testing (recommended for isolated testing)

**Option 1: Direct QEMU (requires KVM)**
```bash
# Create QEMU image (run as root)
sudo ./create-qemu-image.sh

# Launch QEMU VM
./launch-qemu.sh

# In the VM, run setup script
./setup-vm.sh

# Then run development
./run-dev-docker.sh
```

**Option 2: QEMU in Docker with GUI Window (recommended)**
```bash
# Run QEMU GUI test directly in Docker (creates new image)
./run-qemu-docker.sh

# Or run with existing QCOW2 image
./run-qemu-with-image.sh ./debian13-trixie-docker.qcow2
```

## QEMU Image Management

### Creating QCOW2 Images

```bash
# Create a new Debian 13 image with Docker (requires root)
sudo ./create-qemu-image.sh

# Or use the management script for more options
./manage-qemu-images.sh create [size]
./manage-qemu-images.sh list
./manage-qemu-images.sh info debian13-trixie-docker.qcow2
```

This creates `debian13-trixie-docker.qcow2` (10GB by default).

### Using Existing Images

```bash
# Run QEMU with any QCOW2 image
./run-qemu-with-image.sh /path/to/your/image.qcow2
```

### Image Specifications

- **Format**: QCOW2
- **Size**: 10GB (expandable)
- **OS**: Debian 13 Trixie
- **Pre-installed**: Docker, Rust, SDL2, XFCE desktop
- **Default user**: developer / developer

### Managing QCOW2 Images

Use the management script for common operations:

```bash
# List all images
./manage-qemu-images.sh list

# Get detailed info about an image
./manage-qemu-images.sh info debian13-trixie-docker.qcow2

# Resize an image (+5G to expand by 5GB)
./manage-qemu-images.sh resize debian13-trixie-docker.qcow2 +5G

# Create a backup before modifications
./manage-qemu-images.sh backup debian13-trixie-docker.qcow2

# Create a new image with custom size
./manage-qemu-images.sh create 20G
```

### Mounting Images for Modification

If you need to modify the image contents directly:

```bash
# Install guestfish (for manipulating VM images)
sudo apt-get install libguestfs-tools

# Mount the image
guestmount -a debian13-trixie-docker.qcow2 -i /mnt/qemu-image

# Modify contents in /mnt/qemu-image
# ...

# Unmount
sudo umount /mnt/qemu-image
```

### Image Specifications

- **Format**: QCOW2 (copy-on-write, efficient storage)
- **Default Size**: 10GB (expandable)
- **OS**: Debian 13 Trixie
- **Pre-installed**: Docker, Rust toolchain, SDL2, XFCE desktop
- **Default user**: developer / developer
- **Network**: User-mode networking with port forwarding

## Connecting to VMs

### Direct QEMU Launch
- GUI Window: Direct QEMU window
- VNC: `vncviewer localhost:5900`
- Web VNC: Open http://localhost:6080 in browser
- SSH: `ssh developer@localhost -p 2222` (password: developer)

### Docker-based QEMU
- GUI Window: Direct QEMU window on your desktop
- No VNC needed - displays directly
- SSH: `ssh developer@localhost -p 2222` (password: developer)

### Development Scripts

- `./build.sh` - Build the project
- `./test.sh` - Run tests
- `./run.sh` - Launch the application
- `./test-gui.sh` - Test GUI environment setup
- `./run-qemu-docker.sh` - Run QEMU GUI test in Docker (creates new image)
- `./run-qemu-with-image.sh <image.qcow2>` - Run QEMU with existing QCOW2 image
- `./manage-qemu-images.sh` - Manage QCOW2 images (create, resize, backup, etc.)
- `./diagnose-qemu.sh` - Diagnose QEMU setup issues
- `./test-qemu.sh` - Quick QEMU functionality test
- `./fix-qemu.sh` - Fix QEMU installation issues

## Documentation

Comprehensive documentation is available in the [docs/](docs/) directory:

- [Introduction](docs/introduction.md) - Project overview
- [Setup Guide](docs/setup.md) - Getting started
- [Development Guide](docs/development.md) - Building applications
- [API Reference](docs/api-reference.md) - Complete API docs
- [Examples](docs/examples.md) - Code samples
- [Troubleshooting](docs/troubleshooting.md) - Common issues

## Requirements

- Docker
- Rust (installed in the container)
- SDL2 libraries (installed in the container for Oblivion SDK)
- X11 server (for GUI testing)

## Quick GUI Test

Before running QEMU, test your GUI setup:

```bash
./test-gui.sh
```

This will verify X11, SDL2, QEMU, and Docker are properly configured.

## Troubleshooting QEMU Issues

If you encounter QEMU errors, run the diagnostic tools:

```bash
# Comprehensive diagnostic
./diagnose-qemu.sh

# Quick functionality test
./test-qemu.sh
```

The diagnostic script checks:
- QEMU installation
- KVM access
- Display configuration
- Image availability
- Memory requirements

The test script attempts to run QEMU and shows exact error messages.

### Common QEMU Issues

**"qemu-system-x86_64: Could not access KVM kernel module"**
```bash
# Solution: Run Docker with privileged access
docker run --privileged ...
# Or on host: sudo chmod 666 /dev/kvm
```

**"qemu-system-x86_64: SDL initialization failed"**
```bash
# Solution: Set DISPLAY variable
export DISPLAY=:0
# Or use VNC mode for remote access
```

**"qemu-system-x86_64: Image not found"**
```bash
# Solution: Create image first
sudo ./create-qemu-image.sh
# Or specify correct path
./run-qemu-with-image.sh /path/to/image.qcow2
```

**"qemu-system-x86_64: command not found"**
```bash
# Quick fix: Run the fix script
./fix-qemu.sh

# Or rebuild Docker image
docker build --no-cache -t oblivion-desktop .

# Or install manually in running container
docker run -it --rm oblivion-desktop bash
apt-get update && apt-get install qemu-system-x86-64
```

**"qemu-system-x86_64: Not enough memory"**
```bash
# Solution: Reduce memory allocation in launch-qemu.sh
# Change MEMORY="4G" to MEMORY="2G"
```
