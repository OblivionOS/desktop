use oblivion_ui::components::{Window, HStack, Button, Label};
use oblivion_ui::state::State;
use oblivion_ui::rendering::SDLEngine;
use oblivion_ui::themes::Theme;
use std::rc::Rc;
use std::cell::RefCell;

fn main() -> Result<(), String> {
    println!("OblivionOS Panel starting...");
    println!("Initializing SDL window...");

    let redraw_trigger = Rc::new(RefCell::new(false));
    let title_state = State::new("OblivionOS".to_string(), Rc::clone(&redraw_trigger));

    let mut window = Window::new("OblivionOS Panel".to_string(), 800, 50);
    let mut hstack = HStack::new(10.0).padding(10.0);

    let label = Label::new(title_state.binding());
    hstack.add_child(Box::new(label));

    let button = Button::new("Menu".to_string())
        .on_click(|| {
            println!("Menu clicked");
        });
    hstack.add_child(Box::new(button));

    window.add_child(Box::new(hstack));

    let theme = Theme::default();
    let (mut engine, _redraw_trigger) = SDLEngine::new("OblivionOS Panel", 800, 50).map_err(|e| e.to_string())?;
    engine.run(Box::new(window), &theme, redraw_trigger).map_err(|e| e.to_string())
}