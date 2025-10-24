#!/bin/bash
# Quick test script to verify GUI setup

echo "Testing Oblivion Desktop GUI setup..."

# Test X11 connection
echo "Testing X11 connection..."
if command -v xeyes &> /dev/null; then
    timeout 3 xeyes || echo "X11 test completed"
else
    echo "xeyes not available, skipping X11 test"
fi

# Test SDL2
echo "Testing SDL2..."
cat > /tmp/test_sdl.c << 'EOF'
#include <SDL2/SDL.h>
#include <stdio.h>

int main() {
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        printf("SDL_Init Error: %s\n", SDL_GetError());
        return 1;
    }
    SDL_Window *win = SDL_CreateWindow("Test", 100, 100, 320, 240, SDL_WINDOW_SHOWN);
    if (win == NULL) {
        printf("SDL_CreateWindow Error: %s\n", SDL_GetError());
        SDL_Quit();
        return 1;
    }
    SDL_Delay(1000);
    SDL_DestroyWindow(win);
    SDL_Quit();
    printf("SDL2 test successful\n");
    return 0;
}
EOF

if command -v gcc &> /dev/null && command -v pkg-config &> /dev/null; then
    gcc /tmp/test_sdl.c -o /tmp/test_sdl $(pkg-config --cflags --libs sdl2) 2>/dev/null
    if [ $? -eq 0 ]; then
        timeout 3 /tmp/test_sdl || echo "SDL2 test completed"
    else
        echo "SDL2 compilation failed"
    fi
else
    echo "GCC or pkg-config not available"
fi

# Test Wayland
echo "Testing Wayland..."
if pkg-config --exists wayland-client wayland-server; then
    echo "Wayland libraries available"
else
    echo "Wayland libraries not available"
fi

# Test QEMU
echo "Testing QEMU..."
if command -v qemu-system-x86_64 &> /dev/null; then
    echo "QEMU available: $(qemu-system-x86_64 --version | head -1)"
else
    echo "QEMU not available"
fi

# Test Docker
echo "Testing Docker..."
if command -v docker &> /dev/null; then
    echo "Docker available"
    docker --version
else
    echo "Docker not available"
fi

echo "GUI test completed. If all components are available, you should be able to run:"
echo "  ./run-qemu-docker.sh"