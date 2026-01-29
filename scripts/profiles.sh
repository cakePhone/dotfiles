#!/bin/sh

# Constants
MONITOR_RES="1920x1080"
MONITOR_ID="eDP-1"
POWER_SAVE_HZ="60.32Hz"
PERFORMANCE_HZ="144.42Hz"
POWER_SAVE_PROFILE="power-saver"
PERFORMANCE_PROFILE="balanced"
POWER_UNPLUG_SOUND="power-unplug"
POWER_PLUG_SOUND="power-plug"

# Function to set monitor refresh rate
set_monitor_rate() {
    local refresh_rate=$1
    # Only attempt to set monitor if hyprctl is available
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl keyword monitor "$MONITOR_ID,$MONITOR_RES@${refresh_rate},auto,1"
    fi
}

# Function to set tuned profile and refresh rate
set_profile() {
    local profile=$1
    local refresh_rate=$2
    local message=$3

    set_monitor_rate "$refresh_rate"
    notify-send "Power Profile" "$message"
}

# Toggle between powersave and performance mode
toggle_mode() {
    # Use powerprofilesctl (more modern) when available; fallback to tlp-stat
    local current_profile
    if command -v powerprofilesctl >/dev/null 2>&1; then
        current_profile=$(powerprofilesctl get)
    elif command -v tlp-stat >/dev/null 2>&1; then
        current_profile=$(tlp-stat --mode)
    else
        current_profile="unknown"
    fi

    if [ "$current_profile" = "battery" ] || [ "$current_profile" = "power-saver" ]; then
        set_profile \
            "$POWER_SAVE_PROFILE" \
            "$POWER_SAVE_HZ" \
            "Switched to $POWER_SAVE_PROFILE mode"
    else
        set_profile \
            "$PERFORMANCE_PROFILE" \
            "$PERFORMANCE_HZ" \
            "Switched to $PERFORMANCE_PROFILE mode"
    fi
}

# Play a sound notification
play_sound() {
    local sound_event=$1
    canberra-gtk-play -i "$sound_event"
}

# Main logic
if [ "$1" = "true" ]; then
    # On boot
    local power_state=$(
        upower -i "$(upower -e | grep BAT)" | awk '/state/ {print $2}'
    )
    local current_profile=$(tlp-stat --mode)

    if [ "$power_state" = "discharging" ] &&
        [ "$current_profile" = "AC" ]; then
        set_profile \
            "$POWER_SAVE_PROFILE" \
            "$POWER_SAVE_HZ" \
            "Switched to $POWER_SAVE_PROFILE mode"
    else
        set_profile \
            "$PERFORMANCE_PROFILE" \
            "$PERFORMANCE_HZ" \
            "Switched to $PERFORMANCE_PROFILE mode"
    fi
else
    # Not on boot
    local power_state=$(
        upower -i "$(upower -e | grep BAT)" | awk '/state/ {print $2}'
    )

    if [ "$power_state" = "discharging" ]; then
        # On battery
        play_sound "$POWER_UNPLUG_SOUND"
        set_profile \
            "$POWER_SAVE_PROFILE" \
            "$POWER_SAVE_HZ" \
            "Switched to $POWER_SAVE_PROFILE mode"
    else
        # On AC
        play_sound "$POWER_PLUG_SOUND"
        toggle_mode
    fi
fi
