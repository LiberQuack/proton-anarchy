const SCRIPT_TEMPLATE: &'static str = r#"#!/bin/bash
{proton_prefix}
if ! command -v anarchy-run.sh >/dev/null 2>&1; then
    echo "Error: anarchy-run.sh command not found in PATH"
    exit 1
fi
anarchy-run.sh "{exec_path}"
"#;

const DESKTOP_ENTRY_TEMPLATE: &'static str = "[Desktop Entry]
Name={}
Exec={}
Path={}
Icon={}
Type=Application
Terminal=false
Categories=Game;";

use anyhow::{Context, Result};
use std::fs::File;
use std::io::Write;
use std::path::Path;

use crate::utils::{home_dir, run_command, sanitize_game_name};

pub fn add_shortcut(
    game_dir: Option<&str>,     // Anarchy game data path
    game_name: Option<&str>,    // Game name not formatted
    executable: Option<&str>,   // Game executable path (might come from symlinks)
    shortcut_dir: Option<&str>, // Shortcut dir
    steam_compat_data_path: Option<&str>,
) -> Result<()> {
    let game_dir = match game_dir {
        Some(folder) => folder.to_string(),
        None => crate::gui::pick_folder_dialog(
            "Select game data folder",
            Some(&crate::utils::home_dir()),
        )?,
    };

    let executable = match executable {
        Some(exec) => exec.to_string(),
        None => crate::gui::pick_file_dialog("Select game executable", Some(&game_dir))?,
    };

    let game_name = match game_name {
        Some(name) => name.to_string(),
        None => crate::gui::input_dialog("Enter game name", "Game"),
    };

    let shortcut_dir = match shortcut_dir {
        Some(folder) => folder.to_string(),
        None => {
            crate::gui::pick_folder_dialog("Select folder to place shortcuts", Some(&game_dir))?
        }
    };

    // 2. Determine Proton prefix export
    // TODO: Identify if installation is inside a prefix, check for pfx parent folder till root
    let proton_prefix = if let Some(path) = steam_compat_data_path {
        format!("export STEAM_COMPAT_DATA_PATH='{}'", path)
    } else if Path::new(&game_dir).join("../proton-prefix").exists() {
        format!(
            "export STEAM_COMPAT_DATA_PATH='{}'",
            Path::new(&game_dir)
                .join("../proton-prefix")
                .canonicalize()?
                .display()
        )
    } else {
        String::new()
    };

    // 3. Write launch script
    let script_content = SCRIPT_TEMPLATE
        .replace("{proton_prefix}", &proton_prefix)
        .replace("{exec_path}", &executable);

    let launch_script_path = Path::new(&shortcut_dir).join("launch.sh");
    let mut launch_script = File::create(&launch_script_path).with_context(|| {
        format!(
            "Failed to create launch script at {}",
            launch_script_path.display()
        )
    })?;
    write!(launch_script, "{}", script_content)?;
    drop(launch_script);
    run_command("chmod", &["+x", launch_script_path.to_str().unwrap()], None)?;

    // 7. Extract icon from executable
    let icon_destination = Path::new(&shortcut_dir).join("icon.ico");
    run_command(
        "icoextract",
        &[&executable, icon_destination.to_str().unwrap()],
        None,
    )?;

    // 8. Create .desktop file
    let game_name_sanitized = sanitize_game_name(&game_name);
    let dot_desktop_path = Path::new(&home_dir()).join(format!("{}.desktop", game_name_sanitized));

    let mut dot_desktop_file = File::create(&dot_desktop_path).with_context(|| {
        format!(
            "Failed to create .desktop file at {}",
            dot_desktop_path.display()
        )
    })?;
    write!(
        dot_desktop_file,
        "{}",
        DESKTOP_ENTRY_TEMPLATE
            .replacen("{}", &game_name, 1)
            .replacen("{}", &executable, 1)
            .replacen("{}", &game_dir, 1)
            .replacen("{}", &icon_destination.display().to_string(), 1)
    )?;
    drop(dot_desktop_file);
    run_command("chmod", &["+x", dot_desktop_path.to_str().unwrap()], None)?;

    println!("Created .desktop file {}", dot_desktop_path.display());

    // 10. Add game to Steam via steamtinkerlaunch
    // Ensure steamtinkerlaunch is initialized and set SGDBAPIKEY
    run_command(
        "steamtinkerlaunch",
        &[
            "set",
            "SGDBAPIKEY",
            "global",
            "51b7657fd30db6d19d7572b45ae451c7",
        ],
        None,
    )?;

    // Compose STEAM_COMPAT_MOUNTS
    // TODO: Maybe this is not needed anymore
    //  Steam will allow access to game folder and probably HOME as well
    let steam_compat_mounts = format!(
        "STEAM_COMPAT_MOUNTS=\"$STEAM_COMPAT_MOUNTS:{}\" %command%",
        game_dir,
    );

    run_command(
        "steamtinkerlaunch",
        &[
            "addnonsteamgame",
            "--use-steamgriddbb",
            "--auto-artwork",
            &format!("--appname={}", game_name),
            &format!("--exepath={}", executable),
            "--tags=STANDALONE",
            &format!("--steamgriddb-game-name={}", game_name),
            &format!("-lo={}", steam_compat_mounts),
        ],
        None,
    )?;

    println!("Added to library! Please restart steam");

    Ok(())
}
