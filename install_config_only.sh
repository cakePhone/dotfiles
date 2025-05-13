#!/bin/bash

echo "Moving files to config"

# Source directory for dotfiles
dotfiles_root="$HOME/dotfiles"

# Destination directory for configs
config_root="$HOME/.config"

# Iterate over directories in dotfiles_root
find "$dotfiles_root" -maxdepth 1 -type d -print0 | while IFS= read -r -d $'\0' dotfiles_dir; do
  # Extract directory name from path
  dir_name=$(basename "$dotfiles_dir")

  # Skip the dotfiles root directory itself
  if [ "$dir_name" == "dotfiles" ]; then
    continue
  fi

  # Construct the corresponding config directory path
  config_dir="$config_root/$dir_name"

  # Remove the existing config directory or symlink if it exists
  if [ -d "$config_dir" ]; then
    echo "Removing existing config directory: $config_dir"
    rm -rf "$config_dir"
  elif [ -L "$config_dir" ]; then
    echo "Removing existing symlink: $config_dir"
    rm "$config_dir"
  fi

  # Create the symlink
  echo "Creating symlink: $config_dir -> $dotfiles_dir"
  ln -s "$dotfiles_dir" "$config_dir"

  echo "Done with $dir_name!"
done

# Symlink .zshrc to home directory
zshrc_dotfiles="$dotfiles_root/.zshrc"
zshrc_home="$HOME/.zshrc"

# Check if .zshrc exists in dotfiles
if [ -f "$zshrc_dotfiles" ]; then
  # Remove existing .zshrc if it exists
  if [ -f "$zshrc_home" ]; then
    echo "Removing existing .zshrc"
    rm "$zshrc_home"
  elif [ -L "$zshrc_home" ]; then
    echo "Removing existing symlink .zshrc"
    rm "$zshrc_home"
  fi

  # Create symlink for .zshrc
  echo "Creating symlink: $zshrc_home -> $zshrc_dotfiles"
  ln -s "$zshrc_dotfiles" "$zshrc_home"
  echo "Done with .zshrc!"
else
  echo "Warning: .zshrc not found in dotfiles directory."
fi

echo "All done!"

# move .zshrc to home dir
cp .zshrc ~/.zshrc

