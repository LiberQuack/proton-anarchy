use anyhow::{Context, Result};
use regex::Regex;
use std::process::{Command, Stdio};

pub fn run_command(cmd: &str, args: &[&str], cwd: Option<&str>) -> Result<()> {
    let mut command = Command::new(cmd);
    command.args(args);
    if let Some(dir) = cwd {
        command.current_dir(dir);
    }
    let status = command
        .stdin(Stdio::null())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .with_context(|| format!("Failed to run command: {} {:?}", cmd, args))?;
    if !status.success() {
        anyhow::bail!("Command failed: {} {:?}", cmd, args);
    }
    Ok(())
}

pub fn sanitize_game_name(name: &str) -> String {
    let lower = name.to_lowercase();
    let replaced = lower.replace(|c: char| !c.is_ascii_alphanumeric() && c != '-', "-");
    return Regex::new("-+")
        .unwrap()
        .replace_all(&replaced, "-")
        .to_string();
}

pub fn home_dir() -> String {
    std::env::home_dir()
        .expect("Could not determine home directory")
        .to_string_lossy()
        .to_string()
}
