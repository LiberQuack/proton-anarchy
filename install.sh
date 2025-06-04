#!/bin/bash

#################################
# Setup dependencies
#################################
sudo pacman -S wl-clipboard xclip icoextract
yay -S steamtinkerlaunch-git

##############################
# Setup /opt/games
##############################
GROUP_OWNER="$(stat -c %G /opt/games 2>/dev/null)"

if [ ! -d "/opt/games" ] || [ "$GROUP_OWNER" != "proton-anarchy" ]; then
    echo "Creating /opt/games directory and setting up permissions"

    # Create group "proton-anarchy" if it doesn't exist
    sudo groupadd proton-anarchy

    # Add current user to group "proton-anarchy"
    sudo usermod -a -G proton-anarchy "$USER"
    echo "Added $USER to group 'proton-anarchy'"

    # Create /opt/games directory
    sudo mkdir -p /opt/games
    echo "Created /opt/games directory"

    # Change ownership and permissions so group proton-anarchy can read/write/execute
    sudo chgrp -R proton-anarchy /opt/games
    sudo chmod -R g+rwx /opt/games
    sudo chmod -R g+s /opt/games  # Set group sticky bit so new files inherit group
    echo "Permissions set for group 'proton-anarchy' on /opt/games"

    echo "IMPORTANT!!! Please logout/login or reboot for changes to take effect"
fi
