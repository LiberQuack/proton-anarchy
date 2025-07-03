use anyhow::anyhow;

use pathdiff;
use std::fs::create_dir_all;
use std::os::unix::fs::symlink;
use std::path::Path;

use crate::add_shortcut::add_shortcut;
use crate::gui::{input_dialog, pick_file_dialog, pick_folder_dialog};
use crate::{
    prepare::proton_run,
    utils::{home_dir, run_command},
};

pub fn install_game(executable: Option<String>, name: Option<String>) -> anyhow::Result<()> {
    // 1. Select executable (CLI arg or graphical dialog)
    let exec_path = match executable {
        Some(path) if Path::new(&path).exists() => path,
        _ => pick_file_dialog("Select the installer", None)?,
    };

    // 2. Game name
    let game_name = match name {
        Some(n) => n,
        None => {
            let default_name = Path::new(&exec_path)
                .parent()
                .and_then(|p| p.file_name())
                .unwrap()
                .to_string_lossy()
                .to_string();
            input_dialog("Enter game name", &default_name)
        }
    };

    // 3. Destination directory (graphical dialog)
    let dest_dir = pick_folder_dialog("Select Destination Directory", Some(&home_dir()))?;

    // 4. User setup
    crate::prepare::run_prepare()?;

    // 5. Run install game
    let proton_prefix_path = format!("{}/proton-prefix", dest_dir);
    std::env::set_var("STEAM_COMPAT_DATA_PATH", &proton_prefix_path);
    create_dir_all(&proton_prefix_path)?;
    proton_run(exec_path.clone())?;

    // 6. Pick game folder where game was installed (let win_game_dir)
    let installed_dir = pick_folder_dialog(
        "Select where you installed the game",
        Some(&(proton_prefix_path.clone() + "/pfx/drive_c")),
    )?;

    // 7. Use game folder as initial path for the dialogue; select executable (let win_game_executable)
    run_command(
        "mv",
        &[&installed_dir, &(dest_dir.clone() + "/game-data")],
        None,
    )?;
    let game_data_path = format!("{}/game-data", dest_dir);

    // TODO: relative_target will result something like "../../../........../game-data"
    //  it should be fixed because it has an extra "../" compared to the expected
    let relative_target = pathdiff::diff_paths(&game_data_path, Path::new(&installed_dir))
        .ok_or_else(|| anyhow!("Failed to compute relative path for symlink"))?;
    symlink(&relative_target, &installed_dir)?;

    // 8. Create shortcut
    let win_game_executable =
        pick_file_dialog("Select the game executable", Some(&game_data_path))?;

    // Use Option<&str> for add_shortcut, filling with pickers if needed
    add_shortcut(
        Some(&game_data_path),
        Some(&game_name),
        Some(&win_game_executable),
        Some(&dest_dir),
        Some(&proton_prefix_path),
    )?;

    Ok(())
}
