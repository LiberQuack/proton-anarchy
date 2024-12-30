#!/bin/bash
set -e

############################
# Clones proton-anarchy and update PATH
############################
sudo mkdir -p /var/games/proton-anarchy
sudo chmod 777 /var/games/proton-anarchy
git clone git@github.com:LiberQuack/proton-anarchy.git /var/games/proton-anarchy --depth=1
cat <<'EOF' >> ~/.profile

##################
# Proton anarchy
##################
export PATH="$PATH:/var/games/proton-anarchy/bin"

EOF