# Minimal Debian 13 (Trixie) base for OblivionOS Desktop Development
FROM debian:trixie-slim

# Install essential packages including SDL2 for Oblivion SDK and QEMU for testing
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    pkg-config \
    libssl-dev \
    libsdl2-dev \
    libsdl2-ttf-dev \
    qemu-system-x86 \
    qemu-utils \
    debootstrap \
    grub-pc \
    parted \
    kpartx \
    x11-apps \
    xvfb \
    && rm -rf /var/lib/apt/lists/* \
    docker.io && docker-compose

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create workspace directory
WORKDIR /workspace

# Prepare .rso framework environment
RUN mkdir -p /opt/rso-framework

# Copy project files
COPY . /workspace/

# Create QEMU test environment
RUN mkdir -p /qemu-test && \
    chmod +x /workspace/create-qemu-image.sh && \
    chmod +x /workspace/launch-qemu.sh && \
    chmod +x /workspace/setup-vm.sh

# Create directory for QEMU images
RUN mkdir -p /qemu-images

# Create script to run QEMU with GUI in container
RUN echo '#!/bin/bash\n\
echo "Starting QEMU GUI test environment..."\n\
cd /workspace\n\
\n\
# Check for QEMU image in mounted volume or create if needed\n\
if [ -f "/qemu-images/debian13-trixie-docker.qcow2" ]; then\n\
    echo "Using QEMU image from /qemu-images/"\n\
    IMAGE_PATH="/qemu-images/debian13-trixie-docker.qcow2"\n\
elif [ -f "debian13-trixie-docker.qcow2" ]; then\n\
    echo "Using local QEMU image"\n\
    IMAGE_PATH="debian13-trixie-docker.qcow2"\n\
else\n\
    echo "No QEMU image found. Creating one..."\n\
    echo "Note: This will create a 10GB image and may take several minutes"\n\
    ./create-qemu-image.sh\n\
    IMAGE_PATH="debian13-trixie-docker.qcow2"\n\
fi\n\
\n\
# Verify image exists\n\
if [ ! -f "$IMAGE_PATH" ]; then\n\
    echo "Error: QEMU image not found at $IMAGE_PATH"\n\
    echo "Please ensure the image exists or run create-qemu-image.sh"\n\
    exit 1\n\
fi\n\
\n\
# Launch QEMU with GUI\n\
echo "Launching QEMU VM with GUI..."\n\
echo "Image: $IMAGE_PATH"\n\
echo "Close the QEMU window to exit"\n\
./launch-qemu.sh "$IMAGE_PATH"\n\
' > /workspace/run-qemu-gui.sh && chmod +x /workspace/run-qemu-gui.sh

# Default command
CMD ["/bin/bash"]