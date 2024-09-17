!/bin/bash

handle_error() {
    local origin="$1"
    local error_message="$2"
    local log_file="~/AutoErrors/$origin.log"

    echo "$(date): $error_message" >> "$log_file"

    notify-send "Script Error" "From $origin: \n $error_message"

    exit 1
}
