#!/bin/bash
# Script to run QEMU with external QCOW2 image in Docker

IMAGE_PATH="${1:-./debian13-trixie-docker.qcow2}"

# Check if image exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: QEMU image not found at $IMAGE_PATH"
    echo "Usage: $0 <path-to-qcow2-image>"
    echo "Example: $0 ./debian13-trixie-docker.qcow2"
    exit 1
fi

echo "Running Oblivion Desktop QEMU test with image: $IMAGE_PATH"

# Get absolute path
ABS_IMAGE_PATH=$(realpath "$IMAGE_PATH")
IMAGE_DIR=$(dirname "$ABS_IMAGE_PATH")
IMAGE_NAME=$(basename "$ABS_IMAGE_PATH")

# Check if X11 is available
if [ -z "$DISPLAY" ]; then
    echo "Warning: No DISPLAY environment variable set."
    echo "For GUI display, run: export DISPLAY=:0"
    echo "Or use X11 forwarding if connecting via SSH"
fi

docker run -it --rm \
    --privileged \
    -v "$IMAGE_DIR":/qemu-images \
    -v $(pwd):/workspace \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    --device /dev/dri \
    --device /dev/kvm \
    --name oblivion-qemu-test \
    oblivion-desktop \
    bash -c "cd /workspace && ./run-qemu-gui.sh /qemu-images/$IMAGE_NAME"