#!/usr/bin/env bash

sudo apt-get upgrade -y && sudo apt-get update -y

sudo rm /etc/apt/preferences.d/nosnap.pref
sudo apt install snapd -y

sudo apt install youtube-dl git numlockx tree ffmpeg apt-transport-https vlc \
    tmux thunderbird rsync xfce4-power-manager xfce4-volumed zsh jupyter-notebook \
    docker docker-compose wget gpg audacity diffutils digikam libimage-exiftool-perl flatpak \
    --fix-missing -y

sudo snap install pycharm-community --classic
sudo snap install intellij-idea-community --classic
sudo snap install task --classic
sudo snap install node --classic
sudo snap install bitwarden

# anydesk
if ! command -v anydesk &> /dev/null; then
    wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
    echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list
    sudo apt update && sudo apt install anydesk
else
    echo "anydesk already installed"
fi

# install codium
if ! command -v codium &> /dev/null; then
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
        | gpg --dearmor \
        | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
        | sudo tee /etc/apt/sources.list.d/vscodium.list
    sudo apt update && sudo apt install codium -y
else
    echo "codium already installed"
fi


# install vs code
if ! command -v code &> /dev/null; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt update && sudo apt install code -y
else
    echo "code already installed"
fi


# veracrypt
#sudo wget https://launchpad.net/veracrypt/trunk/1.24-update7/+download/veracrypt-1.24-Update7-Ubuntu-20.10-amd64.deb
#sudo apt-get install ./veracrypt-1.24-Update7-Ubuntu-20.04-amd64.deb

# audacity
# recoll
# python3
# java
# sqlite
# meld
# kleopatra
# insomnium
# golang

exit 0
