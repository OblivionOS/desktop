use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("OblivionOS Wayland Compositor starting...");

    // TODO: Initialize Wayland display and compositor
    // For now, just simulate running
    println!("Compositor initialized. Running event loop...");

    loop {
        println!("Compositor running...");
        sleep(Duration::from_secs(5)).await;
    }
}