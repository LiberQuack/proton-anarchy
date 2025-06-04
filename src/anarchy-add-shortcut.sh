#!/bin/bash
set -e
set -x

#######################################
# Ensure required variables are set
#######################################
INITIAL_DIRECTORY="$(readlink -m "${1:-$(pwd)}")"
echo "Picking directory from $INITIAL_DIRECTORY"

DESTINATION="${DESTINATION:-$(zenity --file-selection --directory --title="Pick game directory" --filename="$INITIAL_DIRECTORY/" 2>/dev/null)}"
GAME_NAME="${GAME_NAME:-$(zenity --entry --title="Game Name" --entry-text "$(basename "$DESTINATION")"  2> /dev/null)}"
GAME_NAME_SANITIZED=$(echo "$GAME_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]]+/-/g; s/-+/-/g; s/[^a-z0-9\-]+//g;')

GAME_LINK_DIR="${GAME_LINK_DIR:-"/opt/games/$GAME_NAME_SANITIZED"}"
if [ ! -e "$GAME_LINK_DIR" ]; then
    echo "Creating symbolic link $GAME_LINK_DIR pointing to $DESTINATION"
    ln -sf "$DESTINATION" "$GAME_LINK_DIR"
fi

echo "Preparing to pick game executable file"
EXECUTABLE="$(zenity --file-selection --title="Select the game executable" --filename="$GAME_LINK_DIR/"  2> /dev/null)"

#######################################
# Create launch script
#######################################
LAUNCH_SCRIPT_PATH="$GAME_LINK_DIR/$GAME_NAME_SANITIZED.sh"

# Uses variable if defined
if [ -n "$STEAM_COMPAT_DATA_PATH" ]; then
    PROTON_PREFIX="export STEAM_COMPAT_DATA_PATH='$STEAM_COMPAT_DATA_PATH'"

# Else uses game directory .proton-prefix if it exists
elif [ -e "$GAME_LINK_DIR/.proton-prefix" ]; then
    PROTON_PREFIX="export STEAM_COMPAT_DATA_PATH='$GAME_LINK_DIR/.proton-prefix'"
fi

echo "====== Launch script content ========="

tee "$LAUNCH_SCRIPT_PATH" <<EOF
#!/bin/bash
$PROTON_PREFIX
/var/games/proton-anarchy/bin/anarchy-run.sh "$EXECUTABLE"
EOF

echo "======================================"
chmod +x "$LAUNCH_SCRIPT_PATH"

#######################################
# Create .desktop
#######################################
echo "Extracting ico from game executable"
ICON_DESTINATION="$(dirname "$EXECUTABLE")/icon.ico"
icoextract "$EXECUTABLE" "$(dirname "$EXECUTABLE")/icon.ico"

echo "Preparing to create .desktop file into $GAME_LINK_DIR"
DOT_DESKTOP_FILE="$GAME_LINK_DIR/${GAME_NAME_SANITIZED}.desktop"

cat <<EOF > "$DOT_DESKTOP_FILE"
[Desktop Entry]
Name=$GAME_NAME
Exec=$LAUNCH_SCRIPT_PATH
Path=$GAME_LINK_DIR
Icon=$ICON_DESTINATION
Type=Application
Terminal=false
Categories=Game;
EOF

chmod +x "$DOT_DESKTOP_FILE"
ln -sf "$DOT_DESKTOP_FILE" "$HOME/Desktop/${GAME_NAME_SANITIZED}.desktop"
echo "Created .desktop and linked it to $HOME/Desktop/${GAME_NAME_SANITIZED}.desktop"

#######################################
# Add game to steam
#######################################
steamtinkerlaunch --version #Forces intialization of ~/.config/steamtinkerlaunch
sed -i 's/^SGDBAPIKEY=.*/SGDBAPIKEY=51b7657fd30db6d19d7572b45ae451c7/' ~/.config/steamtinkerlaunch/global.conf
steamtinkerlaunch addnonsteamgame --use-steamgriddbb --auto-artwork \
    --appname="$GAME_NAME" \
    --exepath="$LAUNCH_SCRIPT_PATH" \
    --tags="STANDALONE" \
    --steamgriddb-game-name="$GAME_NAME" \
    -lo="STEAM_COMPAT_MOUNTS=\"\$STEAM_COMPAT_MOUNTS:/var/games/proton-anarchy:$GAME_LINK_DIR:$DESTINATION\" %command%"

( zenity --info --text="Added to library! Please restart steam"  2> /dev/null & )
echo "Added to library! Please restart steam"
