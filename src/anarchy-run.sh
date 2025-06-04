#!/bin/bash
set -e

EXECUTABLE="$1"

ORIGINAL_PATH="$(pwd)"
echo $ORIGINAL_PATH

SCRIPT_PATH="$0"
SCRIPT_DIR=$(realpath "$(dirname "$SCRIPT_PATH")")
echo "SCRIPT_DIR is $SCRIPT_DIR"

#############################
# Log to console and to a file
#############################
echo "===== $(date) =====" > "$SCRIPT_DIR/anarchy-run.sh.log"
echo "Arguments: $@" >> "$SCRIPT_DIR/anarchy-run.sh.log"
echo "===== Variables ====" >> "$SCRIPT_DIR/anarchy-run.sh.log"
env >> "$SCRIPT_DIR/anarchy-run.sh.log"

# Source the setup variables script with full path
. "$SCRIPT_DIR/anarchy-prepare.sh"

echo "Proton variables scripts finished with status $?"
echo "Proton anarchy folder is: \"$SCRIPT_DIR\""
echo "Proton prefix is: \"$WINEPREFIX\""
echo "Proton executable is: \"$PROTON_EXECUTABLE\""

##############################
# HANDLE EXECUTABLE FROM STEAM
##############################
#if [[ "$EXECUTABLE" == *"steam-launch-wrapper"* ]]; then
#  echo "Detected steam-launch-wrapper"
#  WRAPPER="$(echo $EXECUTABLE | grep -Po ".*--")"
#  EXECUTABLE="$(echo "$EXECUTABLE" | xargs | sed -E 's/.*-- //')"
#fi

#SELECT FILE PROMPT
echo "Checking if file exists $EXECUTABLE"
# Handle relative paths
if [[ -f "$EXECUTABLE" ]]; then
        EXECUTABLE="$EXECUTABLE"
        echo "File exists at $EXECUTABLE"
    else
        # File not found, prompt for selection
        EXECUTABLE=$(zenity --file-selection --title="Select a file" --filename="$ORIGINAL_PATH")
        echo "You selected: $EXECUTABLE"
fi

echo "===== Execution =====" >> "$SCRIPT_DIR/anarchy-run.sh.log"

# This if condition was designed to detect running the game from steam
# (It was meant to extract a custom proton version and set it to this script)

#if [ -n "$STEAM_COMPAT_TOOL_PATHS" ]; then
#    echo "Detected STEAM_COMPAT_TOOL_PATHS" >> "$SCRIPT_DIR/anarchy-run.sh.log"
#PROTON_PATH=$(echo "$STEAM_COMPAT_TOOL_PATHS" | cut -d: -f1)

echo "STEAM_COMPAT_DATA_PATH: $STEAM_COMPAT_DATA_PATH"
echo "PROTON_EXECUTABLE: $PROTON_EXECUTABLE"

# args=""
# for d in /dev/input/js /dev/input/event{0..21}; do
#   [ -e "$d" ] && args+=" --bind /dev/null $d"
# done

# tree /dev/inputev

set -x
"$PROTON_EXECUTABLE" run "$EXECUTABLE"

#bwrap --dev-bind / / $args "$PROTON_EXECUTABLE" run "$EXECUTABLE"
#bwrap $args /bin/bash


# UMU-LAUNCHER DISABLED DUE TO ANNOYANCE WITH MOUNT_PATHS ON STEAM CONTAINER
# (else condition was designed for running games outside steam)

#else
#    echo "Using default proton experimental installation" >> "$SCRIPT_DIR/anarchy-run.sh.log"
#   "/usr/share/steam/compatibilitytools.d/proton-cachyos/proton" run "$(readlink -f "$EXECUTABLE")" >> "$SCRIPT_DIR/anarchy-run.sh.log"
#    $WRAPPER "/home/quack/.local/share/Steam/compatibilitytools.d/GE-Proton9-22/proton" run "$(readlink -f "$EXECUTABLE")" >> "$SCRIPT_DIR/anarchy-run.sh.log"
#    GAMEID=0 umu-run "$(readlink -f "$EXECUTABLE")" >> "$SCRIPT_DIR/anarchy-run.sh.log"
#fi
