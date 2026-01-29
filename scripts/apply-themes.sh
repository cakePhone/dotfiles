#!/usr/bin/env bash
# Apply Catppuccin "mocha" theme with mauve accents across GTK/Qt (best-effort automation)
set -euo pipefail

THEME_REPO="$HOME/.local/share/themes/catppuccin-gtk"
THEME_NAME="Catppuccin-Mocha"
MAUVE="#cba6f7"

echo "[apply-themes] Starting automated theme application: $THEME_NAME (mauve accents)"

# 1) Ensure theme files exist (either packaged or cloned)
if [ -d "$THEME_REPO" ]; then
  echo "[apply-themes] Found cloned catppuccin-gtk repo at $THEME_REPO"
else
  echo "[apply-themes] catppuccin-gtk not found locally — attempting to clone upstream into $THEME_REPO"
  mkdir -p "$(dirname "$THEME_REPO")"
  if command -v git >/dev/null 2>&1; then
    git clone https://github.com/catppuccin/gtk.git "$THEME_REPO" || true
  fi
fi

# If the repo provides an install script, run it for the mocha flavour
if [ -x "$THEME_REPO/install.sh" ]; then
  echo "[apply-themes] Running theme installer script with 'mocha' flavour"
  (cd "$THEME_REPO" && ./install.sh --flavour mocha) || true
fi

# 2) Install or copy a theme directory named $THEME_NAME so GTK engines can pick it
TARGET_THEME_DIR="$HOME/.local/share/themes/$THEME_NAME"
if [ ! -d "$TARGET_THEME_DIR" ]; then
  # try common locations inside the repo
  if [ -d "$THEME_REPO/packaged/$THEME_NAME" ]; then
    cp -r "$THEME_REPO/packaged/$THEME_NAME" "$TARGET_THEME_DIR" || true
  elif [ -d "$THEME_REPO/themes/$THEME_NAME" ]; then
    cp -r "$THEME_REPO/themes/$THEME_NAME" "$TARGET_THEME_DIR" || true
  else
    # fallback: copy entire repo under the target name (some installers expect specific layout)
    cp -r "$THEME_REPO" "$TARGET_THEME_DIR" || true
  fi
fi

# 3) Update GTK 3 and GTK 4 settings to use the theme
mkdir -p "$HOME/.config/gtk-3.0"
mkdir -p "$HOME/.config/gtk-4.0"
cat > "$HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=$THEME_NAME
gtk-icon-theme-name=$THEME_NAME
gtk-font-name=JetBrainsMono Nerd Font 10
EOF

cat > "$HOME/.config/gtk-4.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=$THEME_NAME
gtk-icon-theme-name=$THEME_NAME
gtk-font-name=JetBrainsMono Nerd Font 10
EOF

# 4) Add a small GTK CSS override to nudge accent colours to mauve (best-effort)
mkdir -p "$HOME/.config/gtk-3.0"
cat > "$HOME/.config/gtk-3.0/gtk.css" <<EOF
/* mauve accents override (best-effort) */
widget, * {
}
/* selection and focused items */
selection, .selection, .view:selected, treeview:selected, entry:selected, button:checked, button:active {
  background-color: $MAUVE !important;
  color: #1e1e2e !important;
}
EOF

# GTK4 uses same location; some apps read gtk-3.0 gtk.css for overrides
cp -f "$HOME/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css" 2>/dev/null || true

# 5) Configure Qt6 via qt6ct config file
mkdir -p "$HOME/.config/qt6ct"
cat > "$HOME/.config/qt6ct/qt6ct.conf" <<EOF
[Appearance]
styleName=Fusion
iconTheme=$THEME_NAME

[Fonts]
font=JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0
EOF

# Ensure environment variable to make Qt use qt6ct is present in profile
PROFILE="$HOME/.config/profile"
mkdir -p "$(dirname "$PROFILE")"
grep -qxF 'export QT_QPA_PLATFORMTHEME=qt6ct' "$PROFILE" 2>/dev/null || echo 'export QT_QPA_PLATFORMTHEME=qt6ct' >> "$PROFILE"

echo "[apply-themes] Finished writing config files. Please restart GUI apps to pick up changes."
echo "If a GUI theme installer exists (nwg-look/qt6ct), you can still open it to fine-tune icon/cursor selections." 
