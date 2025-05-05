#!/bin/bash

echo "Moving files to config"
cp -r ./* ~/.config/

# move .zshrc to home dir
cp .zshrc ~/.zshrc