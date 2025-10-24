#!/bin/bash
# Script to run inside QEMU VM to set up VNC and Docker environment

echo "Setting up Oblivion Desktop development environment..."

# Install noVNC if not already installed
if ! command -v websockify &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y novnc websockify
fi

# Configure VNC
sudo mkdir -p /home/developer/.vnc
sudo chown developer:developer /home/developer/.vnc

# Create VNC password
echo "developer" | vncpasswd -f > /home/developer/.vnc/passwd
chmod 600 /home/developer/.vnc/passwd
chown developer:developer /home/developer/.vnc/passwd

# Create VNC startup script
cat > /home/developer/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
# Start OblivionOS session
exec /usr/local/bin/oblivion-session &
EOF

chmod +x /home/developer/.vnc/xstartup
chown developer:developer /home/developer/.vnc/xstartup

# Start VNC server
vncserver :0 -geometry 1280x720

# Start noVNC web interface
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &

# Install Rust if not already installed
if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

# Install Wayland development libraries
sudo apt-get install -y libwayland-dev libxkbcommon-dev libegl1-mesa-dev libgles2-mesa-dev libseat-dev libinput-dev libudev-dev libdbus-1-dev libsystemd-dev

# Clone or update the Oblivion Desktop repository
if [ ! -d "/home/developer/oblivion-desktop" ]; then
    git clone https://github.com/skygenesisenterprise/oblivion-desktop.git /home/developer/oblivion-desktop
else
    cd /home/developer/oblivion-desktop
    git pull
fi

chown -R developer:developer /home/developer/oblivion-desktop

# Build OblivionOS components
cd /home/developer/oblivion-desktop
cargo build --release --workspace

# Install components system-wide
sudo cp target/release/oblivion-session /usr/local/bin/
sudo cp target/release/oblivion-comp /usr/local/bin/
sudo cp target/release/oblivion-shell /usr/local/bin/
sudo cp target/release/oblivion-panel /usr/local/bin/

# Install systemd service
sudo cp oblivion-session.service /etc/systemd/system/
sudo systemctl daemon-reload

# Install desktop file
sudo mkdir -p /usr/share/xsessions
sudo cp oblivion.desktop /usr/share/xsessions/

# Create oblivion user for session
sudo useradd -m -s /bin/bash oblivion || true

echo "OblivionOS setup complete!"
echo "VNC server running on :0"
echo "noVNC web interface on port 6080"
echo ""
echo "To start OblivionOS session:"
echo "  sudo systemctl start oblivion-session"
echo "Or select 'OblivionOS' from display manager"