#!/bin/bash
set -e

echo "Opening folder selection..."
selected_folder=$(zenity --file-selection --directory --title="Select a folder")

find "$selected_folder" -name ".game.sh" | while read -r relative_path; do
    GAME_NAME=$(head -n 2 "$relative_path" | tail -n 1 | sed 's/#//')
    echo "Restoring to library: $GAME_NAME"
    ./proton-steam-add-game.sh "$relative_path" "$GAME_NAME"
    zenity --info --title="Imported game" --text="$GAME_NAME" &
done

wait
zenity --info --title="Success" --text="Please restart Steam"
