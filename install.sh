#!/bin/bash

# Copr repos
sudo dnf copr enable solopasha/hyprland -y
sudo dnf copr enable lihaohong/yazi -y

# Install deps
sudo dnf install libnotify cargo hyprland xdg-desktop-portal-hyprland  hyprpaper hyprpicker hypridle hyprlock hyprshot waybar hyprdim wlogout swaync fastfetch yazi btop -y

chmod +x ./install_config_only.sh
./install_config_only.sh
