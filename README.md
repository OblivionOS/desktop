# desktop
The OblivionOS Desktop Version

## Setup

This repository provides a minimal Debian 13 (Trixie) base for developing the OblivionOS desktop interface using Rust and the Oblivion SDK (SwiftUI-like framework).

### Building the Docker Image

```bash
docker build -t oblivion-desktop .
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
# Run QEMU GUI test directly in Docker
./run-qemu-docker.sh
```

Connect to the VM:
- VNC: `vncviewer localhost:5900` (when running direct)
- Web VNC: Open http://localhost:6080 in browser (when running direct)
- SSH: `ssh developer@localhost -p 2222` (password: developer)
- GUI Window: Direct QEMU window when using Docker option

### Development Scripts

- `./build.sh` - Build the project
- `./test.sh` - Run tests
- `./run.sh` - Launch the application
- `./test-gui.sh` - Test GUI environment setup
- `./run-qemu-docker.sh` - Run QEMU GUI test in Docker

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
