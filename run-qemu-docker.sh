#!/bin/bash
# Script to run QEMU GUI testing in Docker container

echo "Running Oblivion Desktop QEMU GUI test in Docker..."

# Check if X11 is available
if [ -z "$DISPLAY" ]; then
    echo "Warning: No DISPLAY environment variable set."
    echo "For GUI display, run: export DISPLAY=:0"
    echo "Or use X11 forwarding if connecting via SSH"
fi

# Allow X11 connections from Docker
xhost +local:docker 2>/dev/null || true

docker run -it --rm \
    --privileged \
    -v $(pwd):/workspace \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -e XAUTHORITY=/tmp/.docker.xauth \
    -v $XAUTHORITY:/tmp/.docker.xauth \
    --device /dev/dri \
    --device /dev/kvm \
    --device /dev/net/tun \
    --cap-add NET_ADMIN \
    --network host \
    --name oblivion-qemu-test \
    oblivion-desktop \
    /workspace/run-qemu-gui.sh

# Revoke X11 permissions after
xhost -local:docker 2>/dev/null || true