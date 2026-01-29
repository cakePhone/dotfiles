#!/bin/bash

# Get current power state
POWER_STATE=$(upower -i $(upower -e | grep BAT) | grep state | awk '{print $2}')

# Get current profile
CURRENT_PROFILE=$(powerprofilesctl get)

if [ "$POWER_STATE" = "discharging" ]; then
    # On battery: toggle between balanced and power-saver
    if [ "$CURRENT_PROFILE" = "balanced" ]; then
        NEW_PROFILE="power-saver"
    else
        NEW_PROFILE="balanced"
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
fi

# Set new profile
powerprofilesctl set "$NEW_PROFILE"

# Show notification
notify-send "Power Profile" "Switched to $NEW_PROFILE mode"

# Play sound (assuming canberra-gtk-play is available)
canberra-gtk-play -i message