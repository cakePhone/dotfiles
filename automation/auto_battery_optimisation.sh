#!/bin/bash

source ./error_handler.sh

run() {
    GNOME_RANDR=$(which gnome-randr) # YES... I NEED THIS
    current_refresh_rate="$($GNOME_RANDR | grep "*" | awk '{ print $1 }' | cut -d'@' -f2 | cut -d'.' -f1)hz"

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
                $GNOME_RANDR modify -m 1920x1080@144.420 eDP-1
                current_refresh_rate="144hz"
            fi
            if [ "$current_power_mode" = "power-saver" ];
            then
                powerprofilesctl set balanced
                nvidia-settings -c :0 -a "[gpu:0]/GpuPowerMizerMode=1"
                nvidia-settings -c :0 -a "AllowExternalGpus=1"
                nvidia-settings -c :0 -a "[gpu:0]/GPUPowerMizerDefaultMode=1"
                nvidia-settings -c :0 -a "[gpu:0]/GPUGraphicsClockOffset[3]=100"
                nvidia-settings -c :0 -a "[gpu:0]/GPUMemoryTransferRateOffset[3]=200"


                notify-send "Power Mode Changed" "Set to maximum performance"
            fi
        elif [ "$power_source" = "off-line" ];
        then
            echo "On Battery"
            if [ "$current_refresh_rate" = "144hz" ];
            then
                $GNOME_RANDR modify -m 1920x1080@60.317 eDP-1
                current_refresh_rate="60hz"
            fi
            if ! [ "$current_power_mode" = "power-saver" ];
            then
              powerprofilesctl set power-saver
              nvidia-settings -c :0 -a "[gpu:0]/GpuPowerMizerMode=0"
              nvidia-settings -c :0 -a "AllowExternalGpus=0"
              nvidia-settings -c :0 -a "[gpu:0]/GPUPowerMizerDefaultMode=0"
              nvidia-settings -c :0 -a "[gpu:0]/GPUGraphicsClockOffset[3]=0"
              nvidia-settings -c :0 -a "[gpu:0]/GPUMemoryTransferRateOffset[3]=0"

              notify-send "Power Mode Changed" "Set to power saver"
            fi
        else
            echo "What the fuck bro, how's this running?"
            break
        fi
        sleep 5
    done
}

run
