use anyhow::{Context, Result};
use std::env;
use std::fs;
use std::os::unix::fs::symlink;
use std::path::Path;

use crate::utils::{home_dir, run_command};

// TODO: To be refactored into two different functions
//  - Setup Home (Full logic)
//  - Setup Game (Initializes proton and link user)
//
// Probably one of them needs to call the other to make the code more elegant/reusable
pub fn run_prepare() -> Result<()> {
    let home = home_dir();
    let anarchy_dir = format!("{}/.proton-anarchy", home);
    let proton_executable =
        "/home/quack/.local/share/Steam/compatibilitytools.d/proton-cachyos-dxvk-gplasync/proton";

    println!("PROTON_EXECUTABLE: {}", proton_executable);
    std::env::set_var("PROTON_EXECUTABLE", proton_executable);

    let steam_compat_client_install_path = format!("{}/.steam/steam", home);
    std::env::set_var(
        "STEAM_COMPAT_CLIENT_INSTALL_PATH",
        &steam_compat_client_install_path,
    );

    let steam_compat_data_path = env::var("STEAM_COMPAT_DATA_PATH")
        .unwrap_or_else(|_| format!("{}/default-prefix", anarchy_dir));

    println!("STEAM_COMPAT_DATA_PATH: {}", steam_compat_data_path);
    std::env::set_var("STEAM_COMPAT_DATA_PATH", &steam_compat_data_path);

    let wineprefix = format!("{}/pfx", steam_compat_data_path);
    println!("WINEPREFIX: {}", wineprefix);

    // Early exit if prefix exists
    if Path::new(&wineprefix).exists() {
        println!("Prefix already exists at {}", wineprefix);
        return Ok(());
    }

    println!("===================================");
    println!("Setting up default prefix at: {}", steam_compat_data_path);
    fs::create_dir_all(&steam_compat_data_path)?;

    // Initialize proton
    run_command(
        proton_executable,
        &["runinprefix", "cmd.exe", "/c", "exit"],
        Some(&steam_compat_data_path),
    )?;

    // Setup virtual users symlink
    let virtual_users = format!("{}/virtual-users", anarchy_dir);
    fs::create_dir_all(&virtual_users)?;

    // Copy users data
    let users_src = format!("{}/pfx/drive_c/users/", steam_compat_data_path);
    let users_dst = &virtual_users;
    run_command("rsync", &["-avh", &users_src, users_dst], None)?;

    // Remove original users folder
    let orig_users = format!("{}/pfx/drive_c/users", steam_compat_data_path);
    if Path::new(&orig_users).exists() {
        fs::remove_dir_all(&orig_users)?;
    }

    // Link virtual users
    symlink(&virtual_users, &orig_users)
        .with_context(|| format!("Failed to symlink {} -> {}", virtual_users, orig_users))?;

    println!("===================================");
    println!("Proton setup finished!");
    Ok(())
}

pub fn proton_run(path: String) -> Result<()> {
    let proton_exec = env::var("PROTON_EXECUTABLE")?;
    return run_command(&proton_exec, &["run", &path], None);
}
