use oblivion_ui::components::{Window, VStack, Button, Label};
use oblivion_ui::state::State;
use oblivion_ui::rendering::SDLEngine;
use oblivion_ui::themes::Theme;
use std::rc::Rc;
use std::cell::RefCell;

fn main() -> Result<(), String> {
    let redraw_trigger = Rc::new(RefCell::new(false));
    let counter = State::new("0".to_string(), Rc::clone(&redraw_trigger));

    let mut window = Window::new("OblivionOS Desktop".to_string(), 800, 600);
    let mut vstack = VStack::new(10.0).padding(20.0);

    let label = Label::new(counter.binding());
    vstack.add_child(Box::new(label));

    let button = Button::new("Increment".to_string())
        .on_click(move || {
            let current: i32 = counter.get().parse().unwrap_or(0);
            counter.set((current + 1).to_string());
        });
    vstack.add_child(Box::new(button));

    window.add_child(Box::new(vstack));

    let theme = Theme::default();
    let (mut engine, _redraw_trigger) = SDLEngine::new("OblivionOS Desktop", 800, 600).map_err(|e| e.to_string())?;
    engine.run(Box::new(window), &theme, redraw_trigger).map_err(|e| e.to_string())
}