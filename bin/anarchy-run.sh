#!/bin/bash
set -e
set -x

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
echo "Proton folder is: \"$SCRIPT_DIR\""

#Log to console and to a file
echo "===== $(date) =====" > "$SCRIPT_DIR/anarchy-run.sh.log"
echo "Arguments: $@" >> "$SCRIPT_DIR/anarchy-run.sh.log"
echo "===== Variables ====" >> "$SCRIPT_DIR/anarchy-run.sh.log"
env >> "$SCRIPT_DIR/anarchy-run.sh.log"

. "$SCRIPT_DIR/proton-setup-variables.sh"


#SELECT FILE PROMPT
EXECUTABLE="$1"
echo "Checking if file exists $EXECUTABLE from $(pwd)"
if ! [ -e "$EXECUTABLE" ]; then
    EXECUTABLE=$(zenity --file-selection --title="Select a file" --filename="$(pwd)")
    echo "You selected: $EXECUTABLE"
fi

echo "===== Execution =====" >> "$SCRIPT_DIR/anarchy-run.sh.log"
if [ -n "$STEAM_COMPAT_TOOL_PATHS" ]; then
    echo "Detected STEAM_COMPAT_TOOL_PATHS" >> "$SCRIPT_DIR/anarchy-run.sh.log"
    PROTON_PATH=$(echo "$STEAM_COMPAT_TOOL_PATHS" | cut -d: -f1)
    echo "Proton path: $PROTON_PATH" >> "$SCRIPT_DIR/anarchy-run.sh.log"
    "$(readlink -f "$PROTON_PATH/proton")" run "$(readlink -f "$EXECUTABLE")" >> "$SCRIPT_DIR/anarchy-run.sh.log"
else
#    echo "Using default proton experimental installation" >> "$SCRIPT_DIR/anarchy-run.sh.log"
#    "/usr/share/steam/compatibilitytools.d/proton-cachyos/proton" run "$(readlink -f "$EXECUTABLE")" >> "$SCRIPT_DIR/anarchy-run.sh.log"
    "/home/quack/.local/share/Steam/compatibilitytools.d/GE-Proton9-18/proton" run "$(readlink -f "$EXECUTABLE")" >> "$SCRIPT_DIR/anarchy-run.sh.log"
#GAMEID=0 umu-run "$(readlink -f "$EXECUTABLE")" >> "$SCRIPT_DIR/anarchy-run.sh.log"
fi
