#!/bin/bash
set -e

ORIGINAL_PATH="$(pwd)"
echo "$ORIGINAL_PATH"

SCRIPT_PATH="$0"
SCRIPT_DIR=$(realpath "$(dirname "$SCRIPT_PATH")")
echo "SCRIPT_DIR is $SCRIPT_DIR"

EXECUTABLE=$(realpath "$1" || echo "")
GAME_NAME=$2

#################################
# Setup proton data and variables
#################################
. "$SCRIPT_DIR/anarchy-prepare.sh"

######################################
# Prepare installation
######################################
if ! [ -e "$EXECUTABLE" ]; then
    echo "No executable path passed as arguments, triggering zenity file selection"
    EXECUTABLE=$(zenity --file-selection --title="Select the installer" --filename="$ORIGINAL_PATH" 2> /dev/null)
    echo "You selected: $EXECUTABLE"
fi

echo "Preparing to install non steam game $EXECUTABLE"
export GAME_NAME="${GAME_NAME:-$(zenity --entry --title="Game Name" --entry-text "$(basename "$(dirname "$EXECUTABLE")")"  2> /dev/null)}"
export GAME_NAME_SANITIZED=$(echo "$GAME_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]]+/-/g; s/-+/-/g; s/[^a-z0-9\-]+//g;')
echo "Sanitized game name is $GAME_NAME_SANITIZED"

export DESTINATION="$(zenity --file-selection --directory --title="Select Destination Directory" --filename="$(dirname "$ORIGINAL_PATH")/"  2> /dev/null)"
export DESTINATION="$(zenity --entry --title="Confirm Destination" --entry-text="$DESTINATION/$GAME_NAME_SANITIZED"  2> /dev/null)"
export GAME_NAME_SANITIZED="$(basename "$DESTINATION")"

mkdir -p "$DESTINATION"
sudo chgrp proton-anarchy "$DESTINATION"
chmod g+s "$DESTINATION"
echo "Created diretory $DESTINATION for group 'proton-anarchy'"

export GAME_LINK_DIR="/opt/games/$GAME_NAME_SANITIZED"
if [ ! -e "$GAME_LINK_DIR" ]; then
    echo "Creating symbolic link at $GAME_LINK_DIR pointing to $DESTINATION"
    ln -sf "$DESTINATION" "$GAME_LINK_DIR"
fi

PROTON_LINK="Z:$(echo "$GAME_LINK_DIR" | sed -E 's/\//\\/g')"
echo "Proton destination is $PROTON_LINK"
( echo "$PROTON_LINK" | wl-copy ) || ( echo "$PROTON_LINK" |  xclip -selection clipboard )
zenity --info --title="Proton destination path utility" --text="$(echo "$PROTON_LINK" | sed -E 's/\\/\\\\/g') copied to your clipboard"  2> /dev/null

##############################
# Prepare game prefix
##############################
export STEAM_COMPAT_DATA_PATH="$GAME_LINK_DIR/.proton-prefix"
. "$SCRIPT_DIR/anarchy-prepare.sh"

##############################
# Run game installer
##############################
echo "Running from ${PWD}"
echo "executable path ${EXECUTABLE}"
"$SCRIPT_DIR/anarchy-run.sh" "$EXECUTABLE" || zenity --question --title="Confirmation" --text="Could not detect successful installation, do you want to continue with steam integration?"  2> /dev/null

##############################
# Create .desktop shortcut
##############################
"$SCRIPT_DIR/anarchy-add-shortcut.sh"
