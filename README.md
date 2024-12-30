# PROTON ANARCHY

Use proton the way you want, not the way you are supposed to!!!


## Remote install
Run the script below
```bash
############################
# Clones proton-anarchy and update PATH
############################
sudo mkdir -p /var/games/proton-anarchy
sudo chmod 777 /var/games/proton-anarchy
git clone git@github.com:LiberQuack/proton-anarchy.git /var/games/proton-anarchy --depth=1
chmod +x /var/games/proton-anarchy/bin/*
cat <<'EOF' >> ~/.profile

##################
# Proton anarchy
##################
export PATH="$PATH:/var/games/proton-anarchy/bin"

EOF
echo 'source ~/.profile' >> ~/.config/plasma-workspace/env/profile.sh

echo "Success!!!"
echo "please logout and login again"
```