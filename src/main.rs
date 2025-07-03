use clap::{Parser, Subcommand};

mod add_shortcut;
mod gui;
mod install_game;
mod prepare;
mod utils;

#[derive(Parser)]
#[command(author, version, about)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Install a non-Steam game
    InstallGame {
        /// Path to the installer executable
        #[arg(short, long)]
        executable: Option<String>,
        /// Game name
        #[arg(short, long)]
        name: Option<String>,
    },
    /// Add a shortcut for a non-Steam game
    AddShortcut {
        /// Game data directory
        #[arg(long)]
        game_dir: Option<String>,
        /// Game name
        #[arg(long)]
        name: Option<String>,
        /// Executable path
        #[arg(long)]
        executable: Option<String>,
        /// Shortcut directory
        #[arg(long)]
        shortcut_dir: Option<String>,
        /// Steam compat data path
        #[arg(long)]
        steam_compat_data_path: Option<String>,
    },
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::InstallGame { executable, name } => install_game::install_game(executable, name)?,
        Commands::AddShortcut {
            game_dir,
            name,
            executable,
            shortcut_dir,
            steam_compat_data_path,
        } => add_shortcut::add_shortcut(
            game_dir.as_deref(),
            name.as_deref(),
            executable.as_deref(),
            shortcut_dir.as_deref(),
            steam_compat_data_path.as_deref(),
        )?,
    }
    Ok(())
}
