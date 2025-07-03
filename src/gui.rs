use dialoguer::Input;
use rfd::FileDialog;

/// Helper to create and configure a FileDialog with a title and optional directory.
fn setup_dialog(title: &str, directory: Option<&str>) -> anyhow::Result<FileDialog> {
    let mut dialog = FileDialog::new();
    dialog = dialog.set_title(title);

    if let Some(dir) = directory {
        dialog = dialog.set_directory(dir);
    } else {
        let original_path = std::env::current_dir()?.to_string_lossy().to_string();
        dialog = dialog.set_directory(&original_path);
    }

    Ok(dialog)
}

/// Opens a file picker dialog with a title and directory.
/// Returns the selected file path as a String, or errors if cancelled.
pub fn pick_file_dialog(title: &str, directory: Option<&str>) -> anyhow::Result<String> {
    let dialog = setup_dialog(title, directory)?;
    dialog
        .pick_file()
        .map(|p| p.display().to_string())
        .ok_or_else(|| anyhow::anyhow!("No file selected"))
}

/// Opens a folder picker dialog with a title and directory.
/// Returns the selected folder path as a String, or errors if cancelled.
pub fn pick_folder_dialog(title: &str, directory: Option<&str>) -> anyhow::Result<String> {
    let dialog = setup_dialog(title, directory)?;
    dialog
        .pick_folder()
        .map(|p| p.display().to_string())
        .ok_or_else(|| anyhow::anyhow!("No folder selected"))
}

/// Prompts the user for input with a prompt and a default value.
/// Returns the entered value as a String.
pub fn input_dialog(prompt: &str, default: &str) -> String {
    Input::new()
        .with_prompt(prompt)
        .default(default.to_string())
        .interact_text()
        .unwrap_or_else(|_| default.to_string())
}
