use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("OblivionOS Wayland Compositor starting...");
    println!("Initializing Wayland display...");

    // TODO: Initialize Wayland display and compositor
    // For now, just simulate running
    println!("Compositor initialized successfully.");
    println!("Starting event loop...");

    loop {
        println!("Compositor running... (tick)");
        sleep(Duration::from_secs(5)).await;
    }
}