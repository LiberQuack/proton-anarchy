#!/bin/bash
set -e

# Determine if the script is sourced or executed
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    # Script is sourced
    SCRIPT_PATH="${BASH_SOURCE[0]}"
else
    # Script is executed
    SCRIPT_PATH="$0"
fi

PROTON_FOLDER="$(dirname "$(readlink -f "$SCRIPT_PATH")")"
echo "Your proton scripts are located at $PROTON_FOLDER"

export STEAM_DIR="$HOME/.steam/root"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
export STEAM_COMPAT_DATA_PATH="$PROTON_FOLDER/proton-data"
export WINEPREFIX="$STEAM_COMPAT_DATA_PATH"

echo "Creating proton-data at $STEAM_COMPAT_DATA_PATH"
mkdir -p $STEAM_COMPAT_DATA_PATH

if ! [ -e "$PROTON_FOLDER/proton-data/pfx" ]; then
    echo "Init proton data folder"
    GAMEID=default umu-run "/bin/bash" -c "zenity --info --text 'Initialized proton-data'"
    if ! [ -e "$PROTON_FOLDER/proton-data/pfx" ]; then
        zenity --error --text 'proton-setup failed'
        exit 1
    fi
    rm "$PROTON_FOLDER/proton-data/pfx"
    ln -fs ../proton-data "$PROTON_FOLDER/proton-data/pfx"
else
    echo "proton-data already exists, continuing..."
fi
