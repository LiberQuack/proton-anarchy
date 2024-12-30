#!/bin/bash
set -e

cd /var/games/proton-anarchy
git -c safe.directory=$(pwd) fetch
git -c safe.directory=$(pwd) checkout origin/main -- bin
chmod +x /var/games/proton-anarchy/bin/*

echo "Success"