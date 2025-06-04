cd /var/games/proton-anarchy

# -a: copy permissions, symbolic links, timestamps, group, owner, and device files
# -v: verbose
# -h: log file sizes in human readable sizes MB/GB
rsync -avh ./ ../../../virtual-users
rm -rf ./proton-anarchy/proton-data
