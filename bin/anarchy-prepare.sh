#!/bin/bash
set -e

#################
# Local Variables
#################
export HOME="$(realpath ~)"
export ANARCHY_DIR="$HOME/.proton-anarchy"
export PROTON_EXECUTABLE="/home/quack/.local/share/Steam/compatibilitytools.d/proton-cachyos-dxvk-gplasync/proton"
echo "PROTON_EXECUTABLE: $PROTON_EXECUTABLE"

#####################
# Proton/Wine Variables
#####################
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
export STEAM_COMPAT_DATA_PATH="${STEAM_COMPAT_DATA_PATH:-$ANARCHY_DIR/default-prefix}"
echo "STEAM_COMPAT_DATA_PATH: $STEAM_COMPAT_DATA_PATH"

# Useful for winetricks
export WINEPREFIX="$STEAM_COMPAT_DATA_PATH/pfx"
echo "WINEPREFIX: $WINEPREFIX"

#####################
# Steam soldier container Variables (useful when running the .exe directly on steam)
# - Disabled since avoiding steam container environment makes the script easier to handle
#####################
#export STEAM_COMPAT_MOUNTS="$STEAM_COMPAT_MOUNTS:$ANARCHY_DIR"


##############################################
# EARLY EXIT: if prefix already exists
##############################################
if [ -e "$STEAM_COMPAT_DATA_PATH/pfx" ]; then
    echo "Prefix already exists at $STEAM_COMPAT_DATA_PATH/pfx"
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        return 0
    else
        exit 0
    fi
fi

######################
# Proton setup
######################
echo "==================================="
echo "Setting up default prefix at: $STEAM_COMPAT_DATA_PATH"
mkdir -p $STEAM_COMPAT_DATA_PATH

# Intializes proton
"$PROTON_EXECUTABLE" runinprefix "cmd.exe" "/c exit"

# Setup virtual users symbolic link
echo "Setting up virtual-users folders link"
mkdir -p "$ANARCHY_DIR/virtual-users"

# Extract users data to our virtual-users folders
rsync -avh "$STEAM_COMPAT_DATA_PATH/pfx/drive_c/users/"  "$ANARCHY_DIR/virtual-users/" > /dev/null

# Delete original users folders
rm -rf "$STEAM_COMPAT_DATA_PATH/pfx/drive_c/users"

# Link virtual users
ln -fs "$ANARCHY_DIR/virtual-users" "$STEAM_COMPAT_DATA_PATH/pfx/drive_c/users"

echo "==================================="
echo "Proton setup finished!"
