#!/bin/bash

# record-menu.sh - Screen recording workflow for Hyprland using Walker and gpu-screen-recorder

# Configuration
RECORDINGS_DIR="$HOME/Videos/Recordings"
RECORDER="gpu-screen-recorder"
WALKER="walker --dmenu"
NOTIFY_SEND="notify-send"

# Ensure recordings directory exists
mkdir -p "$RECORDINGS_DIR"

# Check if recording is active
is_recording() {
    pgrep -f "$RECORDER" > /dev/null
}



# Generate timestamped filename
get_filename() {
    echo "$RECORDINGS_DIR/$(date +%Y%m%d_%H%M%S).mp4"
}

# Select a window
select_window() {
    local windows
    windows=$(hyprctl clients -j | jq -r '.[] | "\(.address) \(.title)"')
    if [ -z "$windows" ]; then
        $NOTIFY_SEND "No Windows" "No windows found"
        return 1
    fi
    local choice
    choice=$(echo -e "$windows" | $WALKER)
    if [ -z "$choice" ]; then
        return 1
    fi
    # Parse address
    echo "$choice" | awk '{print $1}'
}



# Stop recording
stop_recording() {
    if is_recording; then
        pkill -f "$RECORDER"
        FILENAME=$(ls -t "$RECORDINGS_DIR"/*.mp4 | head -1)
        $NOTIFY_SEND "Recording Stopped" "Saved to: $FILENAME"
    else
        $NOTIFY_SEND "No Active Recording" "No recording process found"
    fi
}

# Start recording
start_recording() {
    local mode="$1"
    local filename
    filename=$(get_filename)

    local cmd=("$RECORDER" "-f" "$filename" "-a")

    case "$mode" in
        window)
            local address
            address=$(select_window)
            if [ $? -ne 0 ] || [ -z "$address" ]; then
                $NOTIFY_SEND "Recording Cancelled" "No window selected"
                return
            fi
            cmd+=("-w" "$address")
            ;;
        monitor)
            # wf-recorder records the focused monitor by default
            ;;
    esac

    $NOTIFY_SEND "Recording Started" "Mode: $mode\nFile: $filename"

    # Run in background
    "${cmd[@]}" &
}

# Main menu
main() {
    if is_recording; then
        stop_recording
        exit 0
    fi

    local options="Record Window\nRecord Monitor\nRecord Window (With Mic)\nRecord Monitor (With Mic)"
    local choice
    choice=$(echo -e "$options" | $WALKER)

    case "$choice" in
        "Record Window")
            start_recording "window" "false"
            ;;
        "Record Monitor")
            start_recording "monitor" "false"
            ;;
        "Record Window (With Mic)")
            start_recording "window" "true"
            ;;
        "Record Monitor (With Mic)")
            start_recording "monitor" "true"
            ;;
        *)
            exit 0
            ;;
    esac
}

main "$@"
