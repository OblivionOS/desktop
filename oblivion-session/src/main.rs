
use tokio::process::Command as TokioCommand;
use anyhow::{Result, Context};

#[tokio::main]
async fn main() -> Result<()> {
    println!("OblivionOS Session Manager starting...");

    // Set environment variables for Wayland
    std::env::set_var("WAYLAND_DISPLAY", "wayland-0");
    std::env::set_var("XDG_SESSION_TYPE", "wayland");

    // Start the Wayland compositor
    println!("Starting Wayland compositor...");
    let mut compositor = TokioCommand::new("./target/release/oblivion-comp")
        .spawn()
        .context("Failed to start compositor")?;

    // Wait a moment for compositor to initialize
    tokio::time::sleep(tokio::time::Duration::from_secs(2)).await;

    // Start the desktop panel
    println!("Starting desktop panel...");
    let mut panel = TokioCommand::new("./target/release/oblivion-panel")
        .spawn()
        .context("Failed to start panel")?;

    // Start the desktop shell
    println!("Starting desktop shell...");
    let mut shell = TokioCommand::new("./target/release/oblivion-shell")
        .spawn()
        .context("Failed to start shell")?;

    // Wait for any process to exit
    tokio::select! {
        result = compositor.wait() => {
            println!("Compositor exited: {:?}", result);
        }
        result = panel.wait() => {
            println!("Panel exited: {:?}", result);
        }
        result = shell.wait() => {
            println!("Shell exited: {:?}", result);
        }
    }

    println!("Session manager shutting down...");
    Ok(())
}