#!/bin/bash
# Script to run Oblivion Desktop development in Docker with GUI support

echo "Building Oblivion Desktop Docker image..."
docker build -t oblivion-desktop .

echo "Running Oblivion Desktop in Docker with GUI..."
docker run -it --rm \
    -v $(pwd):/workspace \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -e SDL_VIDEODRIVER=x11 \
    --device /dev/dri \
    --privileged \
    oblivion-desktop

echo "Development session ended."