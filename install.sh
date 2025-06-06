#!/bin/bash
set -e

#################################
# Setup dependencies
#################################
echo "Preparing to install dependencies (icoextract/wl-clipboard/git/...)"
sudo pacman -Sy wl-clipboard xclip icoextract git
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

# Setup proton-anarchy
echo "Downloading proton-anarchy"
mkdir -p ~/.local/src
rm -rf ~/.local/src/proton-anarchy
git clone https://github.com/LiberQuack/proton-anarchy.git ~/.local/src/proton-anarchy --depth=1

echo "Adding ~/.local/src/proton-anarchy/bin to your PATH"
mkdir -p ~/.config/environment.d
cat <<'EOF' > ~/.config/environment.d/proton-anarchy.conf
PATH=${PATH}:~/.local/src/proton-anarchy/bin
EOF

echo "IMPORTANT!!! Please logout/login or reboot for changes to take effect"
