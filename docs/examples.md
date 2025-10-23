# Examples

This section provides practical examples of building applications with the Oblivion SDK.

## Basic Counter App

```rust
use oblivion_ui::components::{Window, VStack, Button, Label};
use oblivion_ui::state::State;
use oblivion_ui::rendering::SDLEngine;
use oblivion_ui::themes::Theme;

fn main() -> Result<(), String> {
    let counter = State::new(0);

    let mut window = Window::new("Counter App".to_string(), 400, 300);
    let mut vstack = VStack::new(20.0).padding(20.0);

    let label = Label::new(counter.binding().map(|x| format!("Count: {}", x)));
    vstack.add_child(Box::new(label));

    let increment_button = Button::new("Increment".to_string())
        .on_click(move || {
            counter.set(counter.get() + 1);
        });
    vstack.add_child(Box::new(increment_button));

    let decrement_button = Button::new("Decrement".to_string())
        .on_click(move || {
            counter.set(counter.get() - 1);
        });
    vstack.add_child(Box::new(decrement_button));

    window.add_child(Box::new(vstack));

    let theme = Theme::default();
    let mut engine = SDLEngine::new("Counter App", 400, 300)?;
    engine.run(Box::new(window), &theme)
}
```

## Todo List Application

```rust
use oblivion_ui::components::{Window, VStack, HStack, Button, Label, Input};
use oblivion_ui::state::State;
use oblivion_ui::rendering::SDLEngine;
use oblivion_ui::themes::Theme;

#[derive(Clone)]
struct TodoItem {
    text: String,
    completed: bool,
}

fn main() -> Result<(), String> {
    let todos = State::new(Vec::<TodoItem>::new());
    let new_todo_text = State::new(String::new());

    let mut window = Window::new("Todo App".to_string(), 600, 400);
    let mut vstack = VStack::new(10.0).padding(20.0);

    // Input for new todos
    let mut input_hstack = HStack::new(10.0);
    let input = Input::new(new_todo_text.binding(), "Enter new todo...".to_string());
    input_hstack.add_child(Box::new(input));

    let add_button = Button::new("Add".to_string())
        .on_click(move || {
            let text = new_todo_text.get();
            if !text.is_empty() {
                let mut current_todos = todos.get();
                current_todos.push(TodoItem {
                    text: text.clone(),
                    completed: false,
                });
                todos.set(current_todos);
                new_todo_text.set(String::new());
            }
        });
    input_hstack.add_child(Box::new(add_button));
    vstack.add_child(Box::new(input_hstack));

    // Todo list
    let todo_list = todos.binding().map(|todo_items| {
        let mut list_vstack = VStack::new(5.0);
        for (index, item) in todo_items.iter().enumerate() {
            let mut item_hstack = HStack::new(10.0);

            let status = if item.completed { "[✓]" } else { "[ ]" };
            let label = Label::new(State::new(format!("{} {}", status, item.text)).binding());
            item_hstack.add_child(Box::new(label));

            let toggle_button = Button::new("Toggle".to_string())
                .on_click(move || {
                    let mut current_todos = todos.get();
                    if let Some(todo) = current_todos.get_mut(index) {
                        todo.completed = !todo.completed;
                    }
                    todos.set(current_todos);
                });
            item_hstack.add_child(Box::new(toggle_button));

            list_vstack.add_child(Box::new(item_hstack));
        }
        list_vstack
    });

    // This is a simplified example - in practice you'd need to handle the dynamic component
    // For now, just display a placeholder
    let placeholder = Label::new(State::new("Todo list would go here".to_string()).binding());
    vstack.add_child(Box::new(placeholder));

    window.add_child(Box::new(vstack));

    let theme = Theme::default();
    let mut engine = SDLEngine::new("Todo App", 600, 400)?;
    engine.run(Box::new(window), &theme)
}
```

## Calculator Application

```rust
use oblivion_ui::components::{Window, VStack, HStack, Button, Label};
use oblivion_ui::state::State;
use oblivion_ui::rendering::SDLEngine;
use oblivion_ui::themes::Theme;

fn main() -> Result<(), String> {
    let display = State::new("0".to_string());
    let first_operand = State::new(None::<f64>);
    let operation = State::new(None::<char>);

    let mut window = Window::new("Calculator".to_string(), 300, 400);
    let mut vstack = VStack::new(10.0).padding(20.0);

    // Display
    let display_label = Label::new(display.binding()).padding(10.0).border(2.0);
    vstack.add_child(Box::new(display_label));

    // Button grid
    let buttons = [
        ("7", "8", "9", "/"),
        ("4", "5", "6", "*"),
        ("1", "2", "3", "-"),
        ("0", "C", "=", "+"),
    ];

    for row in buttons.iter() {
        let mut hstack = HStack::new(5.0);
        for &btn_text in row.iter() {
            let button = Button::new(btn_text.to_string())
                .on_click(move || {
                    handle_button_click(btn_text, &display, &first_operand, &operation);
                });
            hstack.add_child(Box::new(button));
        }
        vstack.add_child(Box::new(hstack));
    }

    window.add_child(Box::new(vstack));

    let theme = Theme::default();
    let mut engine = SDLEngine::new("Calculator", 300, 400)?;
    engine.run(Box::new(window), &theme)
}

fn handle_button_click(
    btn_text: &str,
    display: &State<String>,
    first_operand: &State<Option<f64>>,
    operation: &State<Option<char>>,
) {
    match btn_text {
        "C" => {
            display.set("0".to_string());
            first_operand.set(None);
            operation.set(None);
        }
        "=" => {
            if let (Some(first), Some(op)) = (first_operand.get(), operation.get()) {
                if let Ok(second) = display.get().parse::<f64>() {
                    let result = match op {
                        '+' => first + second,
                        '-' => first - second,
                        '*' => first * second,
                        '/' => first / second,
                        _ => second,
                    };
                    display.set(result.to_string());
                    first_operand.set(None);
                    operation.set(None);
                }
            }
        }
        "+" | "-" | "*" | "/" => {
            if let Ok(num) = display.get().parse::<f64>() {
                first_operand.set(Some(num));
                operation.set(Some(btn_text.chars().next().unwrap()));
                display.set("0".to_string());
            }
        }
        _ => {
            let current = display.get();
            if current == "0" {
                display.set(btn_text.to_string());
            } else {
                display.set(format!("{}{}", current, btn_text));
            }
        }
    }
}
```

## Custom Component Example

```rust
use oblivion_ui::components::{Component, Window, VStack};
use oblivion_ui::rendering::{Renderer, SDLEngine};
use oblivion_ui::themes::Theme;
use oblivion_ui::Event;

pub struct ProgressBar {
    progress: f32, // 0.0 to 1.0
    width: f32,
    height: f32,
}

impl ProgressBar {
    pub fn new(progress: f32, width: f32, height: f32) -> Self {
        Self {
            progress: progress.max(0.0).min(1.0),
            width,
            height,
        }
    }
}

impl Component for ProgressBar {
    fn render(&self, renderer: &mut dyn Renderer, _theme: &Theme) {
        // Draw background
        renderer.set_color(200, 200, 200);
        renderer.draw_rect(0.0, 0.0, self.width, self.height);

        // Draw progress
        renderer.set_color(0, 150, 255);
        let progress_width = self.width * self.progress;
        renderer.draw_rect(0.0, 0.0, progress_width, self.height);

        // Draw border
        renderer.set_color(0, 0, 0);
        renderer.draw_line(0.0, 0.0, self.width, 0.0);
        renderer.draw_line(self.width, 0.0, self.width, self.height);
        renderer.draw_line(self.width, self.height, 0.0, self.height);
        renderer.draw_line(0.0, self.height, 0.0, 0.0);
    }

    fn handle_event(&mut self, _event: &Event) {
        // Progress bar doesn't handle events in this example
    }
}

fn main() -> Result<(), String> {
    let mut window = Window::new("Progress Bar Demo".to_string(), 400, 200);
    let mut vstack = VStack::new(20.0).padding(20.0);

    let progress_bar = ProgressBar::new(0.7, 300.0, 30.0);
    vstack.add_child(Box::new(progress_bar));

    window.add_child(Box::new(vstack));

    let theme = Theme::default();
    let mut engine = SDLEngine::new("Progress Bar Demo", 400, 200)?;
    engine.run(Box::new(window), &theme)
}
```

## Theming Example

```rust
use oblivion_ui::components::{Window, VStack, Button, Label};
use oblivion_ui::state::State;
use oblivion_ui::rendering::SDLEngine;
use oblivion_ui::themes::Theme;

fn main() -> Result<(), String> {
    let counter = State::new(0);

    let mut window = Window::new("Themed App".to_string(), 400, 300);
    let mut vstack = VStack::new(20.0).padding(20.0);

    let label = Label::new(counter.binding().map(|x| format!("Count: {}", x)));
    vstack.add_child(Box::new(label));

    let button = Button::new("Increment".to_string())
        .on_click(move || {
            counter.set(counter.get() + 1);
        });
    vstack.add_child(Box::new(button));

    window.add_child(Box::new(vstack));

    // Custom dark theme
    let theme = Theme {
        primary_color: (100, 150, 255),
        secondary_color: (80, 120, 200),
        background_color: (30, 30, 30),
        text_color: (255, 255, 255),
        font_size: 16,
    };

    let mut engine = SDLEngine::new("Themed App", 400, 300)?;
    engine.run(Box::new(window), &theme)
}
```

These examples demonstrate various aspects of the Oblivion SDK. Start with the basic counter app and gradually add complexity as you become familiar with the framework.