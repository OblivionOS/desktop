# desktop
The OblivionOS Desktop Version

## Setup

This repository provides a minimal Debian 13 (Trixie) base for developing the OblivionOS desktop interface using Rust and the .rso framework.

### Building the Docker Image

```bash
docker build -t oblivion-desktop .
```

### Running the Development Environment

```bash
docker run -it --rm oblivion-desktop
```

### Development Scripts

- `./build.sh` - Build the project
- `./test.sh` - Run tests
- `./run.sh` - Launch the application

## Requirements

- Docker
- Rust (installed in the container)
