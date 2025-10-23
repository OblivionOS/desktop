# Troubleshooting Guide

## Common Issues

### Docker Build Failures

#### Issue: "Permission denied" when building Docker image

**Solution**: Ensure Docker daemon is running and you have proper permissions.

```bash
# Check Docker status
sudo systemctl status docker

# Start Docker if needed
sudo systemctl start docker

# Add user to docker group (Linux)
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

#### Issue: Network timeout during build

**Solution**: Check internet connectivity and retry.

```bash
# Retry build
docker build --no-cache -t oblivion-desktop .
```

#### Issue: Out of disk space

**Solution**: Clean up Docker resources.

```bash
# Remove unused containers and images
docker system prune -a

# Check disk usage
df -h
```

### Rust Compilation Issues

#### Issue: "error: linker `cc` not found"

**Solution**: Install build essentials in container.

The Dockerfile should include `build-essential`, but if running outside Docker:

```bash
sudo apt-get install build-essential
```

#### Issue: SDL2 library not found

**Solution**: Install SDL2 development libraries.

```bash
sudo apt-get install libsdl2-dev libsdl2-ttf-dev
```

#### Issue: Rust version mismatch

**Solution**: Update Rust toolchain.

```bash
rustup update
```

#### Issue: Cargo dependency resolution failed

**Solution**: Clear cargo cache and retry.

```bash
cargo clean
rm -rf ~/.cargo/registry
cargo build
```

### Runtime Issues

#### Issue: Application won't start - "SDL2: No available video device"

**Solution**: Ensure X11 forwarding or proper display setup.

When running in Docker:

```bash
# For X11 forwarding (Linux)
docker run -it --rm -v $(pwd):/workspace \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  oblivion-desktop
```

#### Issue: Window doesn't appear

**Solution**: Check SDL2 initialization and error messages.

Add debug output:

```rust
let mut engine = SDLEngine::new("My App", 800, 600).expect("Failed to create SDL engine");
println!("SDL engine created successfully");
```

#### Issue: Text rendering issues

**Solution**: Ensure SDL2_ttf is properly installed and fonts are available.

```bash
# Check SDL2_ttf
pkg-config --libs SDL2_ttf

# Install fonts if needed
sudo apt-get install fonts-dejavu
```

#### Issue: Performance issues

**Solution**: Profile the application and optimize rendering.

- Reduce unnecessary redraws
- Use efficient data structures
- Minimize state updates

### Development Environment Issues

#### Issue: Changes not reflected

**Solution**: Ensure proper volume mounting.

```bash
docker run -it --rm -v $(pwd):/workspace oblivion-desktop
```

#### Issue: Permission issues with mounted volumes

**Solution**: Adjust file permissions or use consistent user IDs.

```bash
# In Dockerfile, add user with matching UID
RUN useradd -u 1000 -m developer
USER developer
```

### SDK-Specific Issues

#### Issue: Component not rendering

**Solution**: Check component implementation.

Ensure the component implements the `Component` trait correctly:

```rust
impl Component for MyComponent {
    fn render(&self, renderer: &mut dyn Renderer, theme: &Theme) {
        // Implementation required
    }

    fn handle_event(&mut self, event: &Event) {
        // Implementation required
    }
}
```

#### Issue: State not updating UI

**Solution**: Ensure state changes trigger updates.

State changes should automatically trigger re-renders. If not:

- Verify state is being modified correctly
- Check that components are bound to the state
- Ensure the event loop is running

#### Issue: Event not handled

**Solution**: Check event propagation.

Events bubble up from child to parent components. Ensure:

- Child components handle events first
- Parent components can override if needed
- Event types match expected handlers

### Cross-Platform Issues

#### Issue: ARM64 compilation fails

**Solution**: Install ARM64 target and dependencies.

```bash
rustup target add aarch64-unknown-linux-gnu
sudo apt-get install gcc-aarch64-linux-gnu
```

#### Issue: Different behavior on different platforms

**Solution**: Test on target platforms and use conditional compilation.

```rust
#[cfg(target_arch = "x86_64")]
// x86_64 specific code

#[cfg(target_arch = "aarch64")]
// ARM64 specific code
```

### Debugging Tips

#### Enable Debug Output

Add logging to your application:

```rust
use std::println;

fn main() {
    println!("Starting application...");
    // ... rest of code
}
```

#### SDL2 Debug Information

Set SDL2 debug environment variables:

```bash
export SDL_DEBUG=1
export SDL_VIDEODRIVER=x11  # or wayland, etc.
```

#### Rust Debug Builds

Use debug builds for better error messages:

```bash
cargo build  # debug build
./target/debug/oblivion-desktop
```

#### Memory Debugging

Use Valgrind for memory issues:

```bash
sudo apt-get install valgrind
valgrind --leak-check=full ./target/debug/oblivion-desktop
```

### Getting Help

If you encounter issues not covered here:

1. Check the [Oblivion SDK repository](https://github.com/skygenesisenterprise/oblivion-sdk) for updates
2. Search existing issues or create a new one
3. Provide detailed error messages and system information
4. Include minimal reproduction code

### System Information

When reporting issues, include:

- OS version: `uname -a`
- Rust version: `rustc --version`
- Cargo version: `cargo --version`
- Docker version: `docker --version`
- SDL2 version: `pkg-config --modversion sdl2`
- Full error output