# API Reference

## Core Modules

### oblivion_ui::components

Contains all UI components and the Component trait.

#### Trait Component

```rust
pub trait Component {
    fn render(&self, renderer: &mut dyn Renderer, theme: &Theme);
    fn handle_event(&mut self, event: &Event);
}
```

#### Window

Root container for applications.

```rust
pub struct Window {
    pub title: String,
    pub width: u32,
    pub height: u32,
    children: Vec<Box<dyn Component>>,
}

impl Window {
    pub fn new(title: String, width: u32, height: u32) -> Self
    pub fn add_child(&mut self, child: Box<dyn Component>)
}
```

#### VStack

Vertical stack layout.

```rust
pub struct VStack {
    spacing: f32,
    padding: f32,
    border: f32,
    children: Vec<Box<dyn Component>>,
}

impl VStack {
    pub fn new(spacing: f32) -> Self
    pub fn padding(self, padding: f32) -> Self
    pub fn border(self, border: f32) -> Self
    pub fn add_child(&mut self, child: Box<dyn Component>)
}
```

#### HStack

Horizontal stack layout.

```rust
pub struct HStack {
    spacing: f32,
    padding: f32,
    border: f32,
    children: Vec<Box<dyn Component>>,
}

impl HStack {
    pub fn new(spacing: f32) -> Self
    pub fn padding(self, padding: f32) -> Self
    pub fn border(self, border: f32) -> Self
    pub fn add_child(&mut self, child: Box<dyn Component>)
}
```

#### Grid

2D grid layout.

```rust
pub struct Grid {
    rows: usize,
    cols: usize,
    spacing: f32,
    children: Vec<Vec<Option<Box<dyn Component>>>>,
}

impl Grid {
    pub fn new(rows: usize, cols: usize, spacing: f32) -> Self
    pub fn set_child(&mut self, row: usize, col: usize, child: Box<dyn Component>)
}
```

#### Panel

Container with optional styling.

```rust
pub struct Panel {
    border_width: f32,
    padding: f32,
    child: Option<Box<dyn Component>>,
}

impl Panel {
    pub fn new(border_width: f32, padding: f32) -> Self
    pub fn child(self, child: Box<dyn Component>) -> Self
}
```

#### Button

Clickable button.

```rust
pub struct Button {
    label: String,
    padding: f32,
    border: f32,
    on_click: Option<Box<dyn FnMut()>>,
}

impl Button {
    pub fn new(label: String) -> Self
    pub fn padding(self, padding: f32) -> Self
    pub fn border(self, border: f32) -> Self
    pub fn on_click<F>(self, f: F) -> Self
        where F: FnMut() + 'static
}
```

#### Label

Text display component.

```rust
pub struct Label {
    text: Binding<String>,
    padding: f32,
}

impl Label {
    pub fn new(text: Binding<String>) -> Self
    pub fn padding(self, padding: f32) -> Self
}
```

#### Toggle

On/off switch.

```rust
pub struct Toggle {
    is_on: Binding<bool>,
    on_toggle: Option<Box<dyn FnMut(bool)>>,
}

impl Toggle {
    pub fn new(is_on: Binding<bool>) -> Self
    pub fn on_toggle<F>(self, f: F) -> Self
        where F: FnMut(bool) + 'static
}
```

#### Input

Text input field.

```rust
pub struct Input {
    text: Binding<String>,
    placeholder: String,
}

impl Input {
    pub fn new(text: Binding<String>, placeholder: String) -> Self
}
```

### oblivion_ui::state

State management system.

#### State<T>

Reactive state container.

```rust
pub struct State<T> {
    value: RefCell<T>,
    subscribers: RefCell<Vec<Box<dyn Fn()>>>,
}

impl<T: Clone + 'static> State<T> {
    pub fn new(initial: T) -> Self
    pub fn get(&self) -> T
    pub fn set(&self, new_value: T)
    pub fn binding(&self) -> Binding<T>
}
```

#### Binding<T>

Shared reference to state.

```rust
pub struct Binding<T> {
    state: Rc<State<T>>,
}

impl<T: Clone> Binding<T> {
    pub fn get(&self) -> T
    pub fn set(&self, new_value: T)
}
```

### oblivion_ui::rendering

Rendering engine.

#### Trait Renderer

Abstract rendering interface.

```rust
pub trait Renderer {
    fn draw_text(&mut self, text: &str, x: f32, y: f32);
    fn draw_rect(&mut self, x: f32, y: f32, w: f32, h: f32);
    fn draw_line(&mut self, x1: f32, y1: f32, x2: f32, y2: f32);
    fn set_color(&mut self, r: u8, g: u8, b: u8);
    fn clear(&mut self);
    fn present(&mut self);
}
```

#### SDLEngine

SDL2-based rendering engine.

```rust
pub struct SDLEngine {
    window: sdl2::video::Window,
    canvas: sdl2::render::Canvas<sdl2::video::Window>,
    event_pump: sdl2::EventPump,
    ttf_context: sdl2::ttf::Sdl2TtfContext,
}

impl SDLEngine {
    pub fn new(title: &str, width: u32, height: u32) -> Result<Self, String>
    pub fn run(&mut self, root_component: Box<dyn Component>, theme: &Theme) -> Result<(), String>
}
```

### oblivion_ui::themes

Theming system.

#### Theme

Color and font configuration.

```rust
pub struct Theme {
    pub primary_color: (u8, u8, u8),
    pub secondary_color: (u8, u8, u8),
    pub background_color: (u8, u8, u8),
    pub text_color: (u8, u8, u8),
    pub font_size: u32,
}

impl Theme {
    pub fn default() -> Self
}
```

## Events

### Event Enum

```rust
pub enum Event {
    Click { x: f32, y: f32 },
    Hover { x: f32, y: f32 },
    KeyPress(char),
    Drag { dx: f32, dy: f32 },
    Resize { width: u32, height: u32 },
}
```

## Error Handling

Most functions return `Result<T, String>` for error handling. SDL2 errors are propagated as strings.