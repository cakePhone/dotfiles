#!/bin/bash

source ./error_handler.sh

run() {
    current_refresh_rate="$(gnome-randr | grep "*" | awk '{ print $1 }' | cut -d'@' -f2 | cut -d'.' -f1)hz"

    while true
    do
        if ! command -v acpi &> /dev/null;
        then
            echo "acpi not found"
        fi

        local power_source=$(acpi -a | awk '{print $3}')
        local current_power_mode=$(powerprofilesctl get)

        if [ "$power_source" = "on-line" ];
        then
            echo "On AC"
            if [ "$current_refresh_rate" = "60hz" ];
            then
                gnome-randr modify -m 1920x1080@144.420 eDP-1
                current_refresh_rate="144hz"
            fi
            if [ "$current_power_mode" = "power-saver" ];
            then
                powerprofilesctl set balanced
            fi
        elif [ "$power_source" = "off-line" ];
        then
            echo "On Battery"
            if [ "$current_refresh_rate" = "144hz" ];
            then
                gnome-randr modify -m 1920x1080@60.317 eDP-1
                current_refresh_rate="60hz"
            fi
            if ! [ "$current_power_mode" = "power-saver" ];
            then
                powerprofilesctl set power-saver
            fi
        else
            echo "What the fuck bro, how's this running?"
            break
        fi
        sleep 5
    done
}

run
