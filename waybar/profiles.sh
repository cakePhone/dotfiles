#!/bin/sh
power_state=$(upower -i $(upower -e | grep BAT) | awk '/state/ {print $2}')
current=$(sudo tuned-adm active | awk '{print $4}')
if [ "$power_state" = "discharging" ]; then
    canberra-gtk-play -i power-unplug
    # On battery, always switch to powersave if not already
    if [ "$current" != "powersave" ]; then
        sudo tuned-adm profile powersave
        hyprctl keyword monitor "eDP-1,1920x1080@60.32Hz,auto,1"
        notify-send "Power Profile" "Switched to Power Saver mode (on battery)"
    else 
        notify-send "Power Profile" "Already in Power Saver mode (on battery)"
    fi
else
    canberra-gtk-play -i power-plug
    # On AC, toggle between performance and powersave
    if [ "$current" = "throughput-performance" ]; then
        sudo tuned-adm profile powersave
        hyprctl keyword monitor "eDP-1,1920x1080@60.32Hz,auto,1"
        notify-send "Power Profile" "Switched to Power Saver mode (on AC)"
    else
        sudo tuned-adm profile throughput-performance
        hyprctl keyword monitor "eDP-1,1920x1080@144.42Hz,auto,1"
        notify-send "Power Profile" "Switched to Performance mode (on AC)"

    fi
fi

