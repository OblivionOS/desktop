# Setup Guide

## Prerequisites

Before starting development, ensure you have:

- Docker installed on your system
- Basic knowledge of Rust programming
- Familiarity with Linux development

## Getting the Code

Clone the OblivionOS Desktop repository:

```bash
git clone https://github.com/skygenesisenterprise/oblivion-desktop.git
cd oblivion-desktop
```

## Building the Development Environment

The project uses Docker to provide a consistent Debian 13 Trixie environment:

```bash
# Build the Docker image
docker build -t oblivion-desktop .

# Run the development container
docker run -it --rm -v $(pwd):/workspace oblivion-desktop
```

## Inside the Container

Once inside the container, you can:

- Build the project: `./build.sh`
- Run tests: `./test.sh`
- Launch the application: `./run.sh`

## Development Workflow

1. Make changes to the Rust code
2. Build using `./build.sh`
3. Test with `./test.sh`
4. Run with `./run.sh` to see the UI

## Dependencies

The Docker image includes:

- Rust toolchain (latest stable)
- SDL2 development libraries
- Essential build tools
- Git for version control

## Troubleshooting

### Docker Issues

- Ensure Docker is running
- Check that you have sufficient disk space
- Verify network connectivity for downloading dependencies

### Build Issues

- Clear cargo cache: `cargo clean`
- Update Rust: `rustup update`
- Check SDL2 installation: `pkg-config --libs sdl2`

### Runtime Issues

- Ensure X11 forwarding for GUI applications
- Check SDL2 runtime libraries
- Verify display environment variables