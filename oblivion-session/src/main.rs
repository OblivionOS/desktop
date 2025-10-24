
use tokio::process::Command as TokioCommand;
use anyhow::{Result, Context};
use std::process::Stdio;
use tokio::fs::File;
use tokio::io::AsyncWriteExt;

async fn start_logging_service() -> Result<()> {
    println!("Starting logging service...");
    // Create log directory if it doesn't exist
    tokio::fs::create_dir_all("/var/log").await
        .context("Failed to create log directory")?;

    let mut log_file = File::create("/var/log/oblivion.log").await
        .context("Failed to create log file")?;

    log_file.write_all(b"OblivionOS logging service started\n").await?;
    println!("Logging service initialized at /var/log/oblivion.log");
    Ok(())
}

async fn start_network_service() -> Result<()> {
    println!("Starting network service...");
    // Simple network setup (placeholder)
    println!("Network service: configuring interfaces...");
    // In a real system, this would configure networking
    println!("Network service ready");
    Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
    println!("OblivionOS Session Manager starting...");

    // Start system services
    if let Err(e) = start_logging_service().await {
        println!("Warning: Failed to start logging service: {}", e);
    }

    if let Err(e) = start_network_service().await {
        println!("Warning: Failed to start network service: {}", e);
    }

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