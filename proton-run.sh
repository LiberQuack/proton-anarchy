#!/bin/bash
set -e
set -x

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
echo "Proton folder is: \"$SCRIPT_DIR\""

#Log to console and to a file
echo "===== $(date) =====" > "$SCRIPT_DIR/proton-last-run.log"
echo "Arguments: $@" >> "$SCRIPT_DIR/proton-last-run.log"
echo "===== Variables ====" >> "$SCRIPT_DIR/proton-last-run.log"
env >> "$SCRIPT_DIR/proton-last-run.log"

. "$SCRIPT_DIR/proton-setup-variables.sh"


#SELECT FILE PROMPT
EXECUTABLE="$1"
echo "Checking if file exists $EXECUTABLE from $(pwd)"
if ! [ -e "$EXECUTABLE" ]; then
    EXECUTABLE=$(zenity --file-selection --title="Select a file" --filename="$(pwd)")
    echo "You selected: $EXECUTABLE"
fi

#RUN BINARY
export PRESSURE_VESSEL_FILESYSTEMS_RW="/var/mnt/kingston_d57c/Games/Guitar Hero 3"
echo "===== Execution =====" >> "$SCRIPT_DIR/proton-last-run.log"
if [ -n "$STEAM_COMPAT_TOOL_PATHS" ]; then
    echo "Detected STEAM_COMPAT_TOOL_PATHS" >> "$SCRIPT_DIR/proton-last-run.log"
    PROTON_PATH=$(echo "$STEAM_COMPAT_TOOL_PATHS" | cut -d: -f1)
    echo "Proton path: $PROTON_PATH" >> "$SCRIPT_DIR/proton-last-run.log"
    "$(readlink -f "$PROTON_PATH/proton")" run "$(readlink -f "$EXECUTABLE")" >> "$SCRIPT_DIR/proton-last-run.log"
else
    echo "Using umu-run utility" >> "$SCRIPT_DIR/proton-last-run.log"
    echo GAMEID=default umu-run "$(readlink -f "$EXECUTABLE")" >> "$SCRIPT_DIR/proton-last-run.log"
    GAMEID=default umu-run "$(readlink -f "$EXECUTABLE")" >> "$SCRIPT_DIR/proton-last-run.log"
fi
