#!/bin/bash
set -e
set -x

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(realpath "$(dirname "$SCRIPT_PATH")")
echo "Moving to directory \"$SCRIPT_DIR\""
cd "$SCRIPT_DIR" || exit

EXECUTABLE=$1
GAME_NAME=$2

. ./proton-setup-variables.sh

if ! [ -e "$EXECUTABLE" ]; then
    EXECUTABLE=$(zenity --file-selection --title="Select a file" --filename="$(pwd)")
    echo "You selected: $EXECUTABLE"
fi

echo "Adding non steam game $EXECUTABLE"
EXECUTABLE_DIR="$(realpath "$(dirname "$EXECUTABLE")")"
EXECUTABLE_DIR="$(zenity --entry --title="Game directory" --entry-text "$EXECUTABLE_DIR")"
EXECUTABLE_RELATIVE=$(realpath --relative-to="$EXECUTABLE_DIR" "$EXECUTABLE")
GAME_NAME="${GAME_NAME:-$(zenity --entry --title="Game Name" --entry-text "$(basename "$EXECUTABLE_DIR")")}"

echo "#### Creating .desktop file"
GAME_NAME_SANITIZED=$(echo "$GAME_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
DESKTOP_FILE="$EXECUTABLE_DIR/$GAME_NAME_SANITIZED.desktop"
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=$GAME_NAME
Exec="$SCRIPT_DIR/proton-run.sh" "$EXECUTABLE_RELATIVE"
Path=$EXECUTABLE_DIR
Icon=application-x-executable
Type=Application
Terminal=false
Categories=Game;
EOF
chmod +x "$DESKTOP_FILE"
ln -s "$DESKTOP_FILE" "$HOME/Desktop/${GAME_NAME_SANITIZED}.desktop"
echo "#### Created .desktop and linked it to $HOME/Desktop/${GAME_NAME_SANITIZED}.desktop"

sed -i 's/^SGDBAPIKEY=.*/SGDBAPIKEY=51b7657fd30db6d19d7572b45ae451c7/' ~/.config/steamtinkerlaunch/global.conf
steamtinkerlaunch addnonsteamgame --use-steamgriddbb --auto-artwork \
    --appname="$GAME_NAME" \
    --exepath="$DESKTOP_FILE" \
    --tags="STANDALONE" \
    --steamgriddb-game-name="$GAME_NAME" \
    -lo="STEAM_COMPAT_MOUNTS=\"\$STEAM_COMPAT_MOUNTS:$SCRIPT_DIR:$(realpath "$EXECUTABLE_DIR")\" %command%"

( zenity --info --text="$GAME added! Please restart steam" & )
echo "$GAME added to steam!!!"
