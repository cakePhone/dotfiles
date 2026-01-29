#!/bin/bash

#!/usr/bin/env bash
# Disable the default input source if it exists; safe to run at startup.
set -euo pipefail

# Prefer the default source name; fallback to first available if not found
DEFAULT_SOURCE=$(pactl info 2>/dev/null | awk -F": " '/Default Source:/ {print $2}') || true
if [ -n "$DEFAULT_SOURCE" ]; then
  pactl set-source-mute "$DEFAULT_SOURCE" true || true
else
  # Try to mute the first input source returned by pactl
  FIRST_SRC=$(pactl list short sources | awk '{print $2}' | head -n1) || true
  if [ -n "$FIRST_SRC" ]; then
    pactl set-source-mute "$FIRST_SRC" true || true
  fi
fi
