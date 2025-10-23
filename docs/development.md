# Development Guide

## Project Structure

```
oblivion-desktop/
├── src/
│   └── main.rs          # Application entry point
├── docs/                # Documentation
├── Dockerfile           # Container definition
├── Cargo.toml           # Rust dependencies
├── build.sh             # Build script
├── test.sh              # Test script
└── run.sh               # Run script
```

## Using the Oblivion SDK

The Oblivion SDK provides SwiftUI-like components for building UIs.

### Basic Application Structure

```rust
use oblivion_ui::components::{Window, VStack, Button, Label};
use oblivion_ui::state::State;
use oblivion_ui::rendering::SDLEngine;
use oblivion_ui::themes::Theme;

fn main() -> Result<(), String> {
    // Create reactive state
    let counter = State::new(0);

    // Create window
    let mut window = Window::new("My App".to_string(), 800, 600);

    // Create layout
    let mut vstack = VStack::new(10.0).padding(20.0);

    // Add components
    let label = Label::new(counter.binding().map(|x| x.to_string()));
    vstack.add_child(Box::new(label));

    let button = Button::new("Increment".to_string())
        .on_click(move || {
            counter.set(counter.get() + 1);
        });
    vstack.add_child(Box::new(button));

    // Set up window
    window.add_child(Box::new(vstack));

    // Run application
    let theme = Theme::default();
    let mut engine = SDLEngine::new("My App", 800, 600)?;
    engine.run(Box::new(window), &theme)
}
```

## State Management

### Local State

```rust
let count = State::new(0);
// Update state
count.set(count.get() + 1);
```

### Shared State

```rust
let shared_state = State::new("Hello".to_string());
let binding = shared_state.binding();
// Use binding in multiple components
```

## Components

### Layout Components

- **Window**: Root container
- **VStack**: Vertical stack
- **HStack**: Horizontal stack
- **Grid**: 2D grid layout
- **Panel**: Container with border/padding

### Interactive Components

- **Button**: Clickable button
- **Label**: Text display
- **Toggle**: On/off switch
- **Input**: Text input field

## Event Handling

Components handle events through the `on_click`, `on_toggle`, etc. methods:

```rust
let button = Button::new("Click me".to_string())
    .on_click(|| {
        println!("Button clicked!");
    });
```

## Theming

Customize appearance with themes:

```rust
let theme = Theme {
    primary_color: (255, 0, 0),
    background_color: (255, 255, 255),
    text_color: (0, 0, 0),
    font_size: 14,
};
```

## Custom Components

Create custom components by implementing the `Component` trait:

```rust
use oblivion_ui::components::Component;
use oblivion_ui::rendering::Renderer;
use oblivion_ui::themes::Theme;

pub struct MyComponent {
    // fields
}

impl Component for MyComponent {
    fn render(&self, renderer: &mut dyn Renderer, theme: &Theme) {
        // Custom rendering logic
    }

    fn handle_event(&mut self, event: &Event) {
        // Event handling
    }
}
```

## Building and Testing

### Development Build

```bash
./build.sh
```

### Release Build

```bash
cargo build --release
```

### Running Tests

```bash
./test.sh
```

### Cross-Compilation

For ARM64:

```bash
rustup target add aarch64-unknown-linux-gnu
cargo build --target aarch64-unknown-linux-gnu
```

## Debugging

- Use `println!` for simple debugging
- SDL2 provides error messages on failure
- Check the console output for runtime errors

## Best Practices

- Keep components small and focused
- Use reactive state for dynamic UIs
- Handle errors gracefully
- Test on multiple screen sizes
- Follow Rust naming conventions