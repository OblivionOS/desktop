# QEMU Testing Environment

This guide explains how to set up and use QEMU for testing Oblivion Desktop in an isolated virtual machine environment.

## Overview

QEMU allows you to run Oblivion Desktop in a virtual machine, providing:

- Isolated testing environment
- GUI rendering via VNC
- Web-based access via noVNC
- Full Debian 13 system with Docker pre-installed

## Prerequisites

- QEMU installed on host system
- KVM support (recommended for performance)
- At least 8GB RAM available
- Sufficient disk space (15GB+ recommended)

### Installing QEMU

**Ubuntu/Debian:**
```bash
sudo apt-get install qemu qemu-kvm libvirt-daemon-system libvirt-clients virt-manager
```

**Arch Linux:**
```bash
sudo pacman -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat
```

**macOS (with Homebrew):**
```bash
brew install qemu
```

## Creating the VM Image

### Using the Automated Script

Run the image creation script as root:

```bash
sudo ./create-qemu-image.sh
```

This will create:
- `debian13-trixie-docker.qcow2`: 10GB QEMU image
- Debian 13 Trixie base system
- Docker pre-installed
- XFCE desktop environment
- VNC and noVNC for remote access

The process takes approximately 10-15 minutes depending on your internet connection.

### Using the Management Script

For more control over image creation:

```bash
# Create default 10GB image
./manage-qemu-images.sh create

# Create custom size image
./manage-qemu-images.sh create 20G

# List all images
./manage-qemu-images.sh list

# Get image information
./manage-qemu-images.sh info debian13-trixie-docker.qcow2
```

## Launching the VM

Start the virtual machine:

```bash
./launch-qemu.sh
```

This launches QEMU with:
- 4GB RAM
- 2 CPU cores
- VNC on port 5900
- Web interface on port 6080
- SSH on port 2222

## Connecting to the VM

### VNC Client

Use any VNC client to connect:

```bash
vncviewer localhost:5900
```

Or with Remmina (Linux):
- Protocol: VNC
- Server: localhost:5900
- Password: developer

### Web VNC

Open your browser and navigate to:
```
http://localhost:6080
```

This provides a web-based VNC interface.

### SSH Access

For command-line access:

```bash
ssh developer@localhost -p 2222
Password: developer
```

## Initial VM Setup

After first boot, run the setup script inside the VM:

```bash
./setup-vm.sh
```

This configures:
- VNC server with XFCE desktop
- noVNC web interface
- Clones the Oblivion Desktop repository
- Sets up development environment

## Running Oblivion Desktop

### Inside the VM

1. Open a terminal in XFCE
2. Navigate to the project directory:
   ```bash
   cd /home/developer/oblivion-desktop
   ```
3. Build and run:
   ```bash
   docker build -t oblivion-desktop .
   ./run-dev-docker.sh
   ```

### From Host Machine

You can also SSH into the VM and run commands remotely:

```bash
ssh developer@localhost -p 2222
cd oblivion-desktop
docker build -t oblivion-desktop .
docker run -it --rm \
  -v $(pwd):/workspace \
  -e DISPLAY=:0 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  oblivion-desktop
```

## Troubleshooting

### VM Won't Start

**Issue:** "KVM not available"
**Solution:** Ensure KVM is enabled in BIOS and you're running as root or in the `kvm` group.

```bash
# Check KVM support
lsmod | grep kvm

# Add user to KVM group
sudo usermod -aG kvm $USER
```

**Issue:** "Network not working"
**Solution:** Check QEMU network configuration and host firewall.

### VNC Connection Issues

**Issue:** Cannot connect to VNC
**Solution:** Ensure VNC server is running in the VM.

```bash
# Inside VM
vncserver -list
vncserver :0  # Start if not running
```

**Issue:** Black screen in VNC
**Solution:** Check XFCE configuration and X11 setup.

### Docker Issues in VM

**Issue:** Docker daemon not running
**Solution:** Start Docker service.

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

**Issue:** Permission denied
**Solution:** Ensure user is in docker group.

```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### Performance Issues

**Issue:** Slow GUI performance
**Solution:**
- Increase VM RAM to 8GB
- Enable KVM acceleration
- Use virtio drivers
- Close unnecessary applications

### Display Issues

**Issue:** SDL application won't render
**Solution:** Ensure proper X11 forwarding.

```bash
# In Docker run command
-e DISPLAY=:0 \
-v /tmp/.X11-unix:/tmp/.X11-unix \
--device /dev/dri
```

## Advanced Configuration

### Custom VM Settings

Edit `launch-qemu.sh` to modify:
- Memory: Change `-m 4G` to desired amount
- CPUs: Change `-smp 2` to desired count
- Ports: Modify hostfwd options for different ports

### Networking

For advanced networking, modify the QEMU command to use bridged networking instead of user networking.

### Shared Folders

To share files between host and VM:

```bash
# Add to QEMU command
-virtfs local,path=/host/path,mount_tag=hostshare,security_model=mapped,id=hostshare

# Mount in VM
sudo mount -t 9p -o trans=virtio hostshare /mnt/host
```

## Development Workflow

1. Make changes on host machine
2. Commit and push to git
3. Pull changes in VM: `git pull`
4. Rebuild Docker image: `docker build -t oblivion-desktop .`
5. Test: `./run-dev-docker.sh`

## Cleanup

To remove the VM:

```bash
# Stop QEMU (Ctrl+C in terminal)
rm debian13-trixie-docker.qcow2
```

## Alternative: Direct Docker Testing

If QEMU is not suitable, you can test directly with Docker:

```bash
# Requires X11 on host
docker run -it --rm \
  -v $(pwd):/workspace \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  oblivion-desktop
```

This is simpler but requires X11 on the host system.

## Docker-based QEMU GUI Testing

The easiest way to test with GUI is using the Docker-based QEMU:

### Running with New Image

```bash
# Run QEMU with GUI window directly in Docker (creates new image)
./run-qemu-docker.sh
```

### Running with Existing Image

```bash
# Run QEMU with your own QCOW2 image
./run-qemu-with-image.sh /path/to/your/image.qcow2
```

These methods:
- Runs QEMU inside a Docker container
- Displays the VM window directly on your desktop
- Requires X11 forwarding
- Works on Linux, macOS, and Windows with WSL2
- Supports any QCOW2 image with Debian/Ubuntu-based systems

### Requirements for Docker QEMU GUI

- X11 server running on host
- Docker with `--privileged` flag
- Access to `/dev/dri` and `/dev/kvm` devices
- QCOW2 image (created or existing)

### Image Management in Docker

You can manage images from within the Docker container:

```bash
# Run container and access management tools
docker run -it --rm -v $(pwd):/workspace oblivion-desktop bash

# Inside container
cd /workspace
./manage-qemu-images.sh list
./manage-qemu-images.sh create 15G
```

### Troubleshooting Docker GUI

**Issue:** "Could not connect to display"
**Solution:** Ensure X11 forwarding is set up:

```bash
# Linux
export DISPLAY=:0

# macOS with XQuartz
export DISPLAY=:0

# Windows WSL2
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
```

**Issue:** "Permission denied" for devices
**Solution:** Run with `--privileged` flag (already included in script)

**Issue:** "QEMU image not found"
**Solution:** Ensure the image path is correct and accessible:

```bash
# Check if image exists
ls -la debian13-trixie-docker.qcow2

# Use absolute path
./run-qemu-with-image.sh $(pwd)/debian13-trixie-docker.qcow2
```

**Issue:** Black screen in QEMU window
**Solution:** The VM may be booting. Wait for the GRUB menu or login screen. Check QEMU logs for errors.