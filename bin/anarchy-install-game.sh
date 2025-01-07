#!/bin/bash
set -e

ORIGINAL_PATH="$(pwd)"
echo $ORIGINAL_PATH

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(realpath "$(dirname "$SCRIPT_PATH")")
cd "$SCRIPT_DIR"

EXECUTABLE=$1
GAME_NAME=$2

. anarchy-setup-variables.sh

if ! [ -e "$EXECUTABLE" ]; then
    EXECUTABLE=$(zenity --file-selection --title="Select the installer" --filename="$(pwd)" 2> /dev/null)
    echo "You selected: $EXECUTABLE"
fi

echo "Preparing to install non steam game $EXECUTABLE"
GAME_NAME="${GAME_NAME:-$(zenity --entry --title="Game Name" --entry-text "$(basename "$(dirname "$EXECUTABLE")")"  2> /dev/null)}"
GAME_NAME_SANITIZED=$(echo "$GAME_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]]+/-/g; s/-+/-/g')
DESTINATION="$(zenity --entry --title="Destination" --entry-text "$(dirname $ORIGINAL_PATH)/$GAME_NAME_SANITIZED"  2> /dev/null)"
mkdir -p "$DESTINATION"

echo "Creating symbolic link"
GAME_LINK_DIR="/var/games/$GAME_NAME_SANITIZED"
ln -sf "$DESTINATION" "$GAME_LINK_DIR"

PROTON_LINK="Z:$(echo "$GAME_LINK_DIR" | sed -E 's/\//\\/g')"
echo "Proton destination is $PROTON_LINK"
( echo "$PROTON_LINK" | wl-copy ) || ( echo "$PROTON_LINK" |  xclip -selection clipboard )
zenity --info --title="Proton destination path utility" --text="$(echo $PROTON_LINK | sed -E 's/\\/\\\\/g') copied to your clipboard"  2> /dev/null
./anarchy-run.sh "$EXECUTABLE" || zenity --question --title="Confirmation" --text="Could not detect successful installation, do you want to continue with steam integration?"  2> /dev/null

echo "Preparing to pick game executable file"
EXECUTABLE="$(zenity --file-selection --title="Select the game executable" --filename="$GAME_LINK_DIR"  2> /dev/null)"

echo "Preparing to create .desktop file into $GAME_LINK_DIR"
DESKTOP_FILE="$GAME_LINK_DIR/${GAME_NAME_SANITIZED}.desktop"

cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=$GAME_NAME
Exec="/var/games/proton-anarchy/anarchy-run" "$EXECUTABLE"
Path=$GAME_LINK_DIR
Icon=application-x-executable
Type=Application
Terminal=false
Categories=Game;
EOF

chmod +x "$DESKTOP_FILE"
ln -s "$DESKTOP_FILE" "$HOME/Desktop/${GAME_NAME_SANITIZED}.desktop"
echo "Created .desktop and linked it to $HOME/Desktop/${GAME_NAME_SANITIZED}.desktop"

sed -i 's/^SGDBAPIKEY=.*/SGDBAPIKEY=51b7657fd30db6d19d7572b45ae451c7/' ~/.config/steamtinkerlaunch/global.conf
steamtinkerlaunch addnonsteamgame --use-steamgriddbb --auto-artwork \
    --appname="$GAME_NAME" \
    --exepath="$DESKTOP_FILE" \
    --tags="STANDALONE" \
    --steamgriddb-game-name="$GAME_NAME" \
    -lo="STEAM_COMPAT_MOUNTS=\"\$STEAM_COMPAT_MOUNTS:$SCRIPT_DIR:$GAME_LINK_DIR:$DESTINATION\" gtk-launch %command%"

( zenity --info --text="$GAME added! Please restart steam"  2> /dev/null & )
echo "$GAME added to steam!!!"
