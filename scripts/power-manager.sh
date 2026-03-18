#!/bin/bash
# Power management script for maximum battery life
# Runs as regular user. Uses sudo tee for privileged sysfs writes.

MONITOR_ID="eDP-1"
POWER_SAVE_MODE="1920x1080@60.32"
PERFORMANCE_MODE="1920x1080@144.42"

detect_wm() {
    if [ -n "$NIRI_SOCKET" ] || [ "$XDG_CURRENT_DESKTOP" = "niri" ]; then
        echo "niri"
    elif [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] || [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
        echo "hyprland"
    else
        echo "unknown"
    fi
}

set_display_mode() {
    local mode="$1"
    local wm="${2:-$(detect_wm)}"
    local res rr rr_int

    case "$wm" in
        niri)
            if ! niri msg output "$MONITOR_ID" mode "$mode" >/dev/null 2>&1; then
                res="${mode%@*}"
                rr="${mode##*@}"
                rr_int="${rr%%.*}"

                if ! niri msg output "$MONITOR_ID" mode "${res}@${rr_int}" >/dev/null 2>&1 && \
                   ! niri msg output "$MONITOR_ID" mode "${res}@${rr_int}.00" >/dev/null 2>&1; then
                    notify-send "Power Profile" "Could not set ${MONITOR_ID} to ${mode} in niri"
                fi
            fi
            ;;
        hyprland)
            hyprctl keyword monitor "$MONITOR_ID,$mode,0x0,1" >/dev/null 2>&1 || true
            ;;
        *)
            ;;
    esac
}

# Helper: write to a sysfs/proc path via sudo tee
syswrite() {
    echo "$2" | sudo tee "$1" >/dev/null 2>&1
}

# Helper: write to all matching glob paths
syswrite_glob() {
    local value="$1"
    shift
    for path in "$@"; do
        [ -f "$path" ] && syswrite "$path" "$value"
    done
}

apply_powersave() {
    # Monitor: 60Hz
    set_display_mode "$POWER_SAVE_MODE" "$WM_TARGET"

    # CPU: powersave governor, 2GHz cap, no turbo, 30% p-state, EPP=power
    syswrite_glob "powersave" /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    syswrite_glob "2000000"   /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
    syswrite_glob "power"     /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
    syswrite /sys/devices/system/cpu/intel_pstate/max_perf_pct 30
    syswrite /sys/devices/system/cpu/intel_pstate/min_perf_pct 10
    syswrite /sys/devices/system/cpu/intel_pstate/no_turbo 1

    # GPU: Intel iGPU boost down, NVIDIA persistence + runtime PM
    syswrite_glob "300" /sys/class/drm/card*/gt_boost_freq_mhz
    if lsmod | grep -q nvidia && command -v nvidia-smi >/dev/null 2>&1; then
        sudo nvidia-smi -pm 1 >/dev/null 2>&1
        syswrite /sys/bus/pci/devices/0000:01:00.0/power/control auto
    fi

    # PCI: runtime PM auto for all devices
    syswrite_glob "auto" /sys/bus/pci/devices/*/power/control

    # USB: autosuspend
    syswrite_glob "auto" /sys/bus/usb/devices/*/power/control
    syswrite_glob "1"    /sys/bus/usb/devices/*/power/autosuspend

    # Storage: SATA min_power, NVMe auto, laptop mode
    syswrite_glob "min_power" /sys/class/scsi_host/host*/link_power_management_policy
    syswrite_glob "auto"      /sys/class/nvme/nvme*/power/control
    syswrite /proc/sys/vm/dirty_writeback_centisecs 6000
    syswrite /proc/sys/vm/dirty_expire_centisecs 1500
    syswrite /proc/sys/vm/laptop_mode 5
    syswrite /proc/sys/vm/swappiness 10
    syswrite /proc/sys/vm/vfs_cache_pressure 50

    # Network: runtime PM + wifi powersave
    syswrite_glob "auto" /sys/class/net/*/device/power/control
    for iface in /sys/class/net/wl*; do
        [ -d "$iface" ] && sudo iw dev "$(basename "$iface")" set power_save on 2>/dev/null
    done

    # Audio: HDA power save
    syswrite /sys/module/snd_hda_intel/parameters/power_save 1
    syswrite /sys/module/snd_hda_intel/parameters/power_save_controller Y

    # Display: brightness 30%
    if [ -f /sys/class/backlight/intel_backlight/brightness ]; then
        local max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
        syswrite /sys/class/backlight/intel_backlight/brightness $((max * 30 / 100))
    fi

    # Bluetooth off
    rfkill block bluetooth 2>/dev/null

    echo "Power saver mode applied"
}

apply_performance() {
    # Monitor: 144Hz
    set_display_mode "$PERFORMANCE_MODE" "$WM_TARGET"

    # CPU: remove caps, turbo on, EPP balanced
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
        if [ -f "$cpu" ]; then
            local max=$(cat "$(dirname "$cpu")/cpuinfo_max_freq" 2>/dev/null)
            [ -n "$max" ] && syswrite "$cpu" "$max"
        fi
    done
    syswrite_glob "balance_performance" /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
    syswrite /sys/devices/system/cpu/intel_pstate/max_perf_pct 100
    syswrite /sys/devices/system/cpu/intel_pstate/min_perf_pct 20
    syswrite /sys/devices/system/cpu/intel_pstate/no_turbo 0

    # GPU: NVIDIA persistence off
    if lsmod | grep -q nvidia && command -v nvidia-smi >/dev/null 2>&1; then
        sudo nvidia-smi -pm 0 >/dev/null 2>&1
    fi

    # PCI: runtime PM on (always active)
    syswrite_glob "on" /sys/bus/pci/devices/*/power/control

    # USB: autosuspend off
    syswrite_glob "on" /sys/bus/usb/devices/*/power/control

    # Storage: SATA max performance, disable laptop mode
    syswrite_glob "max_performance" /sys/class/scsi_host/host*/link_power_management_policy
    syswrite /proc/sys/vm/dirty_writeback_centisecs 500
    syswrite /proc/sys/vm/laptop_mode 0
    syswrite /proc/sys/vm/swappiness 60
    syswrite /proc/sys/vm/vfs_cache_pressure 100

    # Display: brightness 70%
    if [ -f /sys/class/backlight/intel_backlight/brightness ]; then
        local max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
        syswrite /sys/class/backlight/intel_backlight/brightness $((max * 70 / 100))
    fi

    # Bluetooth on
    rfkill unblock bluetooth 2>/dev/null

    echo "Performance mode applied"
}

WM_TARGET="${2:-auto}"
[ "$WM_TARGET" = "auto" ] && WM_TARGET="$(detect_wm)"

case "${1:-}" in
    powersave)  apply_powersave ;;
    performance) apply_performance ;;
    status)
        echo "WM:        $WM_TARGET"
        echo "Governor:  $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)"
        echo "Max Freq:  $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null)"
        echo "Turbo off: $(cat /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null)"
        upower -i "$(upower -e | grep BAT)" 2>/dev/null | grep -E "state|energy-rate|percentage"
        ;;
    *) echo "Usage: $0 {powersave|performance|status} [niri|hyprland|auto]"; exit 1 ;;
esac
