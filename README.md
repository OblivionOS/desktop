# desktop
The OblivionOS Desktop Version

## Setup

This repository provides a minimal Debian 13 (Trixie) base for developing the OblivionOS desktop interface using Rust and the Oblivion SDK (SwiftUI-like framework).

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

## Documentation

Comprehensive documentation is available in the [docs/](docs/) directory:

- [Introduction](docs/introduction.md) - Project overview
- [Setup Guide](docs/setup.md) - Getting started
- [Development Guide](docs/development.md) - Building applications
- [API Reference](docs/api-reference.md) - Complete API docs
- [Examples](docs/examples.md) - Code samples
- [Troubleshooting](docs/troubleshooting.md) - Common issues

## Requirements

- Docker
- Rust (installed in the container)
- SDL2 libraries (installed in the container for Oblivion SDK)
