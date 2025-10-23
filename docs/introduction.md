# Introduction to OblivionOS Desktop Development

## Overview

OblivionOS Desktop is a custom Linux distribution based on Debian 13 (Trixie) that aims to provide a macOS-like user experience. The desktop environment is built using Rust and the Oblivion SDK, a SwiftUI-inspired framework for creating native user interfaces.

## Key Components

- **Base OS**: Debian 13 Trixie (minimal installation)
- **Programming Language**: Rust
- **UI Framework**: Oblivion SDK (SwiftUI-like)
- **Rendering**: SDL2 with OpenGL/Vulkan support
- **Architecture**: x86_64 and ARM64 support

## Goals

- Provide a familiar macOS-like interface on Linux
- Enable rapid development of native applications
- Support both desktop and embedded use cases
- Maintain Debian's stability and package ecosystem

## Architecture

The system is structured as follows:

```
OblivionOS/
├── Base: Debian 13 Trixie
├── Desktop Environment: Custom Rust-based UI
├── SDK: Oblivion UI Framework
├── Applications: Native Rust apps using the SDK
```

## Development Philosophy

- **Declarative UI**: Inspired by SwiftUI, components are described declaratively
- **Reactive State**: Automatic UI updates when state changes
- **Native Performance**: Direct SDL2 rendering for optimal performance
- **Cross-Platform**: Designed to work on multiple architectures