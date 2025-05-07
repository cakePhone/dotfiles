#!/bin/sh

# Constants
MONITOR_RES="1920x1080"
MONITOR_ID="eDP-1"
POWER_SAVE_HZ="60.32Hz"
PERFORMANCE_HZ="144.42Hz"
POWER_SAVE_PROFILE="powersave"
PERFORMANCE_PROFILE="throughput-performance"
POWER_UNPLUG_SOUND="power-unplug"
POWER_PLUG_SOUND="power-plug"

# Function to set monitor refresh rate
set_monitor_rate() {
  local refresh_rate=$1
  hyprctl keyword monitor "$MONITOR_ID,$MONITOR_RES@${refresh_rate},auto,1"
}

# Function to set tuned profile and refresh rate
set_profile() {
  local profile=$1
  local refresh_rate=$2
  local message=$3

  sudo tuned-adm profile "$profile"
  set_monitor_rate "$refresh_rate"
  notify-send "Power Profile" "$message"
}

# Toggle between powersave and performance mode
toggle_mode() {
  local current_profile=$(
    sudo tuned-adm active | awk '{print $4}'
  )

  if [ "$current_profile" != "$POWER_SAVE_PROFILE" ]; then
    set_profile \
      "$POWER_SAVE_PROFILE" \
      "$POWER_SAVE_HZ" \
      "Switched to Power Saver mode"
  else
    set_profile \
      "$PERFORMANCE_PROFILE" \
      "$PERFORMANCE_HZ" \
      "Switched to Performance mode"
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
  local current_profile=$(
    sudo tuned-adm active | awk '{print $4}'
  )

  if [ "$power_state" = "discharging" ] &&
     [ "$current_profile" = "$PERFORMANCE_PROFILE" ]; then
    set_profile \
      "$POWER_SAVE_PROFILE" \
      "$POWER_SAVE_HZ" \
      "Switched to Power Saver mode"
  else
    set_profile \
      "$PERFORMANCE_PROFILE" \
      "$PERFORMANCE_HZ" \
      "Switched to Performance mode"
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
      "Switched to Power Saver mode"
  else
    # On AC
    play_sound "$POWER_PLUG_SOUND"
    toggle_mode
  fi
fi

