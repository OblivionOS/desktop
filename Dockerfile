# Minimal Debian 13 (Trixie) base for OblivionOS Desktop Development
FROM debian:trixie-slim

# Install essential packages including SDL2 for Oblivion SDK
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    pkg-config \
    libssl-dev \
    libsdl2-dev \
    libsdl2-ttf-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create workspace directory
WORKDIR /workspace

# Prepare .rso framework environment
RUN mkdir -p /opt/rso-framework

# Copy project files
COPY . /workspace/

# Default command
CMD ["/bin/bash"]