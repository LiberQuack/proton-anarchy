#!/bin/bash
set -e

cd /var/games/proton-anarchy
git pull
chmod +x /var/games/proton-anarchy/bin/*

echo "Success"