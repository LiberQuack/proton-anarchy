#!/bin/bash
set -e

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
echo "Moving to directory \"$SCRIPT_DIR\""
cd "$SCRIPT_DIR" || exit

echo Moving to directory "$(readlink -f "$(dirname "$0")")"
cd "$(readlink -f "$(dirname "$0")")" || exit

ln -vrsf ./proton-run.sh ~/.local/bin/proton-run.sh
