#!/bin/bash
set -e

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
EXECUTABLE_RELATIVE=$(realpath --relative-to="$EXECUTABLE_DIR" "$EXECUTABLE")
GAME_NAME="${GAME_NAME:-$(zenity --entry --title="Game Name" --entry-text "$EXECUTABLE_DIR/$EXECUTABLE_RELATIVE")}"

if ! [[ "$var" == *.game.sh ]]; then
echo "Creating launcher script... $EXECUTABLE_DIR/.game.sh"
cat <<EOF > "$EXECUTABLE_DIR/.game.sh"
#!/bin/bash
#$GAME_NAME
PATH="$(echo '$PATH:$HOME/.local/bin')"
proton-run.sh '$EXECUTABLE_RELATIVE' &> .game.sh.log
EOF
chmod +x "$EXECUTABLE_DIR/.game.sh"
fi

sed -i 's/^SGDBAPIKEY=.*/SGDBAPIKEY=51b7657fd30db6d19d7572b45ae451c7/' ~/.config/steamtinkerlaunch/global.conf
steamtinkerlaunch addnonsteamgame --use-steamgriddbb --auto-artwork \
    --appname="$GAME_NAME" \
    --exepath="$EXECUTABLE_DIR/.game.sh" \
    --tags="STANDALONE" \
    --steamgriddb-game-name="$GAME_NAME" \
    -lo="STEAM_COMPAT_MOUNTS=\"\$STEAM_COMPAT_MOUNTS:$SCRIPT_DIR:$(realpath "$EXECUTABLE_DIR")\" %command%"

( zenity --info --text="$GAME added! Please restart steam" & )
echo "$GAME added to steam!!!"
