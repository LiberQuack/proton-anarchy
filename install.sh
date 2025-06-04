#!/bin/bash
set -e

#################################
# Setup dependencies
#################################
sudo pacman -S wl-clipboard xclip icoextract
yay -S steamtinkerlaunch-git

##############################
# Setup /opt/games
##############################
echo "Creating group proton-anarchy"

# Create group "proton-anarchy" if it doesn't exist
set +e
sudo groupadd proton-anarchy
if ! getent group proton-anarchy > /dev/null 2>&1; then
    echo "Error: Failed to create group 'proton-anarchy'"
    exit 1
fi
set -e

# Add current user to group "proton-anarchy"
sudo usermod -a -G proton-anarchy "$USER" &&
echo "Added $USER to group 'proton-anarchy'"

# Create /opt/games directory
echo "Creating /opt/games directory and setting up permissions"
sudo mkdir -p /opt/games

# Change ownership and permissions so group proton-anarchy can read/write/execute
sudo chgrp -R proton-anarchy /opt/games
sudo chmod -R g+rwx /opt/games
sudo chmod -R g+s /opt/games  # Set group sticky bit so new files inherit group
echo "Permissions set for group 'proton-anarchy' on /opt/games"

echo "IMPORTANT!!! Please logout/login or reboot for changes to take effect"

mkdir -p ~/.local/src
rm -rf ~/.local/src/proton-anarchy
git clone https://github.com/LiberQuack/proton-anarchy.git ~/.local/src/proton-anarchy
