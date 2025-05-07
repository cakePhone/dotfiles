#!/bin/bash

# Copr repos
sudo dnf copr enable solopasha/hyprland -y
sudo dnf copr enable lihaohong/yazi -y
sudo dnf copr enable pgdev/ghostty -y
sudo dnf copr enable sneexy/zen-browser -y

# Install deps
sudo dnf install zen-browser zsh ghostty libnotify cargo hyprland xdg-desktop-portal-hyprland  hyprpaper hyprpicker hypridle hyprlock hyprshot waybar hyprdim wlogout swaync fastfetch yazi btop -y

# install lvim
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)

# install ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

chmod +x ./install_config_only.sh
./install_config_only.sh
