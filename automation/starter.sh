#!/bin/bash

notify-send "Running scripts" "Check ~/autostart_log.txt for logs" -a "Starter"

cd ~/.config/automation/

./auto_battery_optimisation.sh >> ~/autostart_log.txt 2>&1
./download_sorter.sh >> ~/autostart_log.txt 2>&1
