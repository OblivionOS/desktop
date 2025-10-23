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
exec /usr/bin/startxfce4 &
EOF

chmod +x /home/developer/.vnc/xstartup
chown developer:developer /home/developer/.vnc/xstartup

# Start VNC server
vncserver :0 -geometry 1280x720

# Start noVNC web interface
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &

# Clone or update the Oblivion Desktop repository
if [ ! -d "/home/developer/oblivion-desktop" ]; then
    git clone https://github.com/skygenesisenterprise/oblivion-desktop.git /home/developer/oblivion-desktop
else
    cd /home/developer/oblivion-desktop
    git pull
fi

chown -R developer:developer /home/developer/oblivion-desktop

echo "Setup complete!"
echo "VNC server running on :0"
echo "noVNC web interface on port 6080"
echo ""
echo "To start development:"
echo "  cd /home/developer/oblivion-desktop"
echo "  docker build -t oblivion-desktop ."
echo "  docker run -it --rm -e DISPLAY=:0 -v /tmp/.X11-unix:/tmp/.X11-unix oblivion-desktop"