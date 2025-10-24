#!/bin/bash
# Build script for OblivionOS Desktop

echo "Building OblivionOS Desktop components..."
cargo build --release --workspace

echo "Build completed."