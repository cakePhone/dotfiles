#!/bin/zsh

WM_TARGET="${1:-auto}"

# Get current power state
POWER_STATE=$(upower -i $(upower -e | grep BAT) | grep state | awk '{print $2}')

# Get current profile
CURRENT_PROFILE=$(powerprofilesctl get)

if [ "$POWER_STATE" = "discharging" ]; then
    # On battery: toggle between balanced and power-saver
    if [ "$CURRENT_PROFILE" = "balanced" ]; then
        NEW_PROFILE="power-saver"
        ~/dotfiles/scripts/power-manager.sh powersave "$WM_TARGET"
    else
        NEW_PROFILE="balanced"
        ~/dotfiles/scripts/power-manager.sh performance "$WM_TARGET"
    fi
else
    # On power: toggle between balanced and performance
    if [ "$CURRENT_PROFILE" = "balanced" ]; then
        NEW_PROFILE="performance"
    elif [ "$CURRENT_PROFILE" = "performance" ]; then
        NEW_PROFILE="balanced"
    else
        NEW_PROFILE="balanced"
    fi
    ~/dotfiles/scripts/power-manager.sh performance "$WM_TARGET"
fi

# Set new profile
powerprofilesctl set "$NEW_PROFILE"

# Show notification
notify-send "Power Profile" "Switched to $NEW_PROFILE mode"

# Play sound
canberra-gtk-play -i message
