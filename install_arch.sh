#!/usr/bin/env bash

# Arch installer: installs Hyprland + theme tooling and Catppuccin themes
# Assumes a user with sudo privileges and that 'yay' is available (will install if missing).
set -euo pipefail

echo "[install_arch] Updating system and ensuring build tools..."
sudo pacman -Syu --needed --noconfirm git base-devel

if ! command -v yay >/dev/null 2>&1; then
  echo "[install_arch] 'yay' not found; installing yay from AUR helper bootstrap"
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (cd "$tmpdir/yay" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
fi

echo "[install_arch] Installing Hyprland and utilities (official + AUR where needed)..."
# core packages (official repos where possible)
sudo pacman -S --needed --noconfirm hyprland hyprpaper hyprpicker hypridle hyprlock hyprshot waybar-hyprland wlogout swaync fastfetch yazi btop ghostty zsh qt6ct

# AUR packages via yay (nwg-look and user theme packages)
yay -S --noconfirm zen-browser-bin nwg-look

echo "[install_arch] Installing Catppuccin GTK theme (AUR or git fallback)..."
# Try common AUR package names first; if they fail, fall back to cloning upstream repo
if ! yay -S --noconfirm --needed catppuccin-gtk-theme catppuccin-gtk-theme-git 2>/dev/null; then
  echo "[install_arch] AUR package not found or install failed, attempting to clone upstream"
  THEMES_DIR="$HOME/.local/share/themes"
  mkdir -p "$THEMES_DIR"
  if [ ! -d "$THEMES_DIR/catppuccin-gtk" ]; then
    git clone https://github.com/catppuccin/gtk.git "$THEMES_DIR/catppuccin-gtk" || true
  fi
fi

echo "[install_arch] Ensuring Catppuccin variants (mocha, mauve) are available"
# Many Catppuccin GTK installers expose multiple flavours; if we cloned the repo, make sure the directory exists
THEMES_DIR="$HOME/.local/share/themes"
if [ -d "$THEMES_DIR/catppuccin-gtk" ]; then
  # The repo contains multiple flavours; create simple symlinks for convenience
  for flavour in mocha mauve; do
    dest="$THEMES_DIR/Catppuccin-$flavour"
    if [ ! -e "$dest" ]; then
      cp -r "$THEMES_DIR/catppuccin-gtk" "$dest" || true
    fi
  done
fi

echo "[install_arch] Configure Qt6 to use qt6ct via environment"
# Ensure qt6ct will be used by Qt apps
PROFILE="$HOME/.config/profile"
mkdir -p "$(dirname "$PROFILE")"
grep -qxF 'export QT_QPA_PLATFORMTHEME=qt6ct' "$PROFILE" 2>/dev/null || echo 'export QT_QPA_PLATFORMTHEME=qt6ct' >> "$PROFILE"

echo "[install_arch] Done. Run 'nwg-look' to apply GTK/desktop themes and open 'qt6ct' to tune Qt settings."
