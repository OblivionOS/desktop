use oblivion_ui::components::{Window, VStack, HStack, Button, Label};
use oblivion_ui::state::State;
use oblivion_ui::rendering::SDLEngine;
use oblivion_ui::themes::Theme;
use std::rc::Rc;
use std::cell::RefCell;
use std::sync::{Arc, Mutex};

fn main() -> Result<(), String> {
    println!("OblivionOS Shell starting...");
    println!("Initializing macOS-inspired desktop...");

    let redraw_trigger = Rc::new(RefCell::new(false));

    // Desktop layout: Menu Bar (top) + Main Area + Dock (bottom)
    let mut desktop = VStack::new(0.0);

    // Menu Bar (macOS-style with dark background)
    let mut menu_bar = HStack::new(15.0).padding(8.0);
    menu_bar.add_child(Box::new(Label::new(State::new("🍎 OblivionOS".to_string(), Rc::clone(&redraw_trigger)).binding())));
    menu_bar.add_child(Box::new(Button::new("File".to_string())));
    menu_bar.add_child(Box::new(Button::new("Edit".to_string())));
    menu_bar.add_child(Box::new(Button::new("View".to_string())));
    menu_bar.add_child(Box::new(Button::new("Window".to_string())));
    menu_bar.add_child(Box::new(Button::new("Help".to_string())));
    desktop.add_child(Box::new(menu_bar));

    // Main desktop area (with visual elements)
    let mut main_area_container = VStack::new(20.0).padding(40.0);
    main_area_container.add_child(Box::new(Label::new(State::new("🌟 Welcome to OblivionOS 🌟".to_string(), Rc::clone(&redraw_trigger)).binding())));
    main_area_container.add_child(Box::new(Label::new(State::new("A macOS-inspired Linux desktop in Rust".to_string(), Rc::clone(&redraw_trigger)).binding())));
    main_area_container.add_child(Box::new(Label::new(State::new("Desktop Area - Your application windows will appear here".to_string(), Rc::clone(&redraw_trigger)).binding())));
    main_area_container.add_child(Box::new(Label::new(State::new("💡 Tip: Click the dock icons to launch apps".to_string(), Rc::clone(&redraw_trigger)).binding())));
    desktop.add_child(Box::new(main_area_container));

    // Dock (macOS-style with panel background)
    let mut dock_container = VStack::new(0.0).padding(5.0);
    let mut dock = HStack::new(25.0).padding(15.0);

    // Use Arc<Mutex<bool>> to prevent multiple clicks
    let app1_clicked = Arc::new(Mutex::new(false));
    let app1_clicked_clone = Arc::clone(&app1_clicked);
    dock.add_child(Box::new(Button::new("📱".to_string()).on_click(move || {
        let mut clicked = app1_clicked_clone.lock().unwrap();
        if !*clicked {
            *clicked = true;
            println!("App 1 clicked");
            // Reset after a short delay (simulate debounce)
            let reset = Arc::clone(&app1_clicked_clone);
            std::thread::spawn(move || {
                std::thread::sleep(std::time::Duration::from_millis(200));
                *reset.lock().unwrap() = false;
            });
        }
    })));

    let browser_clicked = Arc::new(Mutex::new(false));
    let browser_clicked_clone = Arc::clone(&browser_clicked);
    dock.add_child(Box::new(Button::new("🌐".to_string()).on_click(move || {
        let mut clicked = browser_clicked_clone.lock().unwrap();
        if !*clicked {
            *clicked = true;
            println!("Browser clicked");
            let reset = Arc::clone(&browser_clicked_clone);
            std::thread::spawn(move || {
                std::thread::sleep(std::time::Duration::from_millis(200));
                *reset.lock().unwrap() = false;
            });
        }
    })));

    let finder_clicked = Arc::new(Mutex::new(false));
    let finder_clicked_clone = Arc::clone(&finder_clicked);
    dock.add_child(Box::new(Button::new("📁".to_string()).on_click(move || {
        let mut clicked = finder_clicked_clone.lock().unwrap();
        if !*clicked {
            *clicked = true;
            println!("Finder clicked");
            let reset = Arc::clone(&finder_clicked_clone);
            std::thread::spawn(move || {
                std::thread::sleep(std::time::Duration::from_millis(200));
                *reset.lock().unwrap() = false;
            });
        }
    })));

    let settings_clicked = Arc::new(Mutex::new(false));
    let settings_clicked_clone = Arc::clone(&settings_clicked);
    dock.add_child(Box::new(Button::new("⚙️ Settings".to_string()).on_click(move || {
        let mut clicked = settings_clicked_clone.lock().unwrap();
        if !*clicked {
            *clicked = true;
            println!("Settings clicked");
            let reset = Arc::clone(&settings_clicked_clone);
            std::thread::spawn(move || {
                std::thread::sleep(std::time::Duration::from_millis(200));
                *reset.lock().unwrap() = false;
            });
        }
    })));

    dock_container.add_child(Box::new(dock));
    desktop.add_child(Box::new(dock_container));

    let mut window = Window::new("OblivionOS Desktop".to_string(), 1280, 800); // More modern resolution
    window.add_child(Box::new(desktop));

    // macOS-inspired theme with vibrant colors
    let mut theme = Theme::default();
    theme.primary_color = (0, 122, 255); // macOS blue
    theme.background_color = (173, 216, 230); // Light blue background (sky blue)
    theme.text_color = (0, 0, 0);
    theme.font_size = 16; // Slightly larger font
    let (mut engine, _redraw_trigger) = SDLEngine::new("OblivionOS Desktop", 1280, 800).map_err(|e| e.to_string())?;
    engine.run(Box::new(window), &theme, redraw_trigger).map_err(|e| e.to_string())
}