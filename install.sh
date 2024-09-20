#!/bin/bash

# Install deps
sudo dnf install libnotify cargo dbus-devel pkgconf-pkg-config -y

cargo install gnome-randr

chmod +x automation/auto_battery_optimisation.sh
chmod +x automation/download_sorter.sh
chmod +x automation/error_handler.sh

# move dotfiles to config
echo "Moving files to config"
cp -r ./* ~/.config/
