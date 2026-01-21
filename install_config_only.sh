#!/bin/bash
set -e

echo "Moving files to config"

# Source directory for dotfiles
dotfiles_root="$HOME/dotfiles"

# Destination directory for configs
config_root="$HOME/.config"

# Ensure config root exists
mkdir -p "$config_root"

# Iterate over directories in dotfiles_root (skip hidden directories and root)
find "$dotfiles_root" -maxdepth 1 -type d -not -path "$dotfiles_root" -not -name '.*' -print0 | while IFS= read -r -d $'\0' dotfiles_dir; do
  dir_name=$(basename "$dotfiles_dir")
  config_dir="$config_root/$dir_name"

  # Remove existing config directory or symlink if it exists
  if [ -e "$config_dir" ] || [ -L "$config_dir" ]; then
    echo "Removing existing: $config_dir"
    rm -rf "$config_dir"
  fi

  # Create the symlink
  echo "Creating symlink: $config_dir -> $dotfiles_dir"
  ln -s "$dotfiles_dir" "$config_dir" || {
    echo "Error: Failed to create symlink for $dir_name"
    exit 1
  }

  echo "Done with $dir_name!"
done

# Symlink .zshrc to home directory
zshrc_dotfiles="$dotfiles_root/.zshrc"
zshrc_home="$HOME/.zshrc"

# Check if .zshrc exists in dotfiles
if [ -f "$zshrc_dotfiles" ]; then
  # Remove existing .zshrc or symlink if it exists
  if [ -e "$zshrc_home" ] || [ -L "$zshrc_home" ]; then
    echo "Removing existing: $zshrc_home"
    rm "$zshrc_home"
  fi

  # Create symlink for .zshrc
  echo "Creating symlink: $zshrc_home -> $zshrc_dotfiles"
  ln -s "$zshrc_dotfiles" "$zshrc_home" || {
    echo "Error: Failed to create symlink for .zshrc"
    exit 1
  }
  echo "Done with .zshrc!"
else
  echo "Warning: .zshrc not found in dotfiles directory."
fi

echo "All done!"
