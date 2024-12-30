#!/bin/bash
set -e

cd /var/games/proton-anarchy
git -c safe.directory=$(pwd) pull
chmod +x /var/games/proton-anarchy/bin/*

echo "Success"