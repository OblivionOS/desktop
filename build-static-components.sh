#!/bin/bash
# Script to build OblivionOS components

set -e

echo "🔨 Building OblivionOS components..."

# Build components normally (dynamic linking for now)
echo "Building oblivion-session..."
cargo build --release -p oblivion-session

echo "Building oblivion-comp..."
cargo build --release -p oblivion-comp

# Note: oblivion-shell and oblivion-panel require SDL2 which can't be easily statically linked
# For now, we'll create simplified versions or skip them for the minimal build

echo "✅ Builds complete!"

# Copy to rootfs if it exists
if [ -d "oblivion-rootfs" ]; then
    echo "📦 Installing components to rootfs..."
    cp target/release/oblivion-session oblivion-rootfs/usr/local/bin/
    cp target/release/oblivion-comp oblivion-rootfs/usr/local/bin/

    # Create simple placeholder scripts for GUI components
    cat > oblivion-rootfs/usr/local/bin/oblivion-shell << 'EOF'
#!/bin/sh
echo "OblivionOS Shell - GUI not available in minimal build"
echo "Run with SDL2 support for full interface"
EOF
chmod +x oblivion-rootfs/usr/local/bin/oblivion-shell

    cat > oblivion-rootfs/usr/local/bin/oblivion-panel << 'EOF'
#!/bin/sh
echo "OblivionOS Panel - GUI not available in minimal build"
echo "Run with SDL2 support for full interface"
EOF
chmod +x oblivion-rootfs/usr/local/bin/oblivion-panel

    echo "✅ Components installed!"
fi