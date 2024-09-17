#!/bin/bash

# Install inotify-utils
sudo dnf install libnotify -y

# move dotfiles to config
echo "Moving files to config"
cp -r ./* ~/.config/
