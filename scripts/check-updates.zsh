#!/bin/bash

function get_update_status() {
    local update_count=0
    local yay_output=""
    local exit_code=0

    yay_output=$(yay -Qu 2>/dev/null)
    exit_code=$?

    if (( exit_code == 0 )); then
        update_count=$(echo "$yay_output" | wc -l)
        echo '{"text": "", "tooltip": "'"$update_count"' packages available", "class": "update-available"}'
    else
        echo '{"text": "", "tooltip": "System up to date", "class": ""}'
    fi
}

get_update_status
