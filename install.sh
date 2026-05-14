#!/usr/bin/env zsh
set -euo pipefail

DOTFILES="${DOTFILES_ROOT:-$HOME/dotfiles}"

echo "[setup] Updating system and ensuring build tools..."
sudo pacman -Syu --needed --noconfirm git base-devel

if ! command -v yay >/dev/null 2>&1; then
  echo "[setup] Installing yay from AUR..."
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (cd "$tmpdir/yay" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
fi

echo "[setup] Installing core packages..."
sudo pacman -S --needed --noconfirm \
  niri swaybg swayidle swaylock swayosd swaync waybar wofi wofi-power-menu \
  wl-clipboard playerctl brightnessctl polkit-gnome qt6ct pavucontrol \
  ghostty yazi btop fastfetch \
  jq upower power-profiles-daemon \
  git neovim zsh \
  noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-meslo-nerd

echo "[setup] Installing AUR packages..."
yay -S --noconfirm --needed \
  zen-browser-bin \
  bibata-cursor-theme-bin

echo "[setup] Symlinking dotfiles to ~/.config/..."
bash "$DOTFILES/install_config_only.sh"

echo "[setup] Symlinking .zprofile..."
rm -f "$HOME/.zprofile"
ln -s "$DOTFILES/.zprofile" "$HOME/.zprofile"

echo "[setup] Deploying systemd user services..."
mkdir -p "$HOME/.config/systemd/user"
cp "$DOTFILES"/systemd/user/*.service "$HOME/.config/systemd/user/"
cp "$DOTFILES"/systemd/user/*.path "$HOME/.config/systemd/user/"
cp -r "$DOTFILES"/systemd/user/niri.service.d "$HOME/.config/systemd/user/" 2>/dev/null || true
systemctl --user daemon-reload

echo "[setup] Building AGS bar..."
bash "$DOTFILES/ags/build.sh"

for unit in swaybg swayidle swayosd polkit-gnome ags; do
  systemctl --user add-wants niri.service "$unit.service"
done

for unit in swaync xdg-desktop-portal-gnome; do
  systemctl --user add-wants niri.service "$unit.service" 2>/dev/null || true
done

echo "[setup] Applying Qt6 theme settings..."
mkdir -p "$HOME/.config"
grep -qxF 'export QT_QPA_PLATFORMTHEME=qt6ct' "$HOME/.config/profile" 2>/dev/null || \
  echo 'export QT_QPA_PLATFORMTHEME=qt6ct' >> "$HOME/.config/profile"

echo "[setup] Deploying silent autologin getty drop-in..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo cp "$DOTFILES/systemd/system/getty@tty1.service.d/autologin.conf" /etc/systemd/system/getty@tty1.service.d/
sudo sed -i "s/--autologin oreo/--autologin $USER/" /etc/systemd/system/getty@tty1.service.d/autologin.conf
sudo systemctl daemon-reload

echo ""
echo "Setup complete. Next steps:"
echo "  1. Place a wallpaper at ~/.config/background"
echo "  2. Add 'vt.global_cursor_default=0 consoleblank=0' to your kernel cmdline"
echo "  3. Reboot"
