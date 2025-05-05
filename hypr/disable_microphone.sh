#!/bin/bash

# Replace with the actual index or name of your input device
INPUT_DEVICE_ID="alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic2__source"  # Or use the index (e.g., 1)

pactl set-source-mute "$INPUT_DEVICE_ID" true
