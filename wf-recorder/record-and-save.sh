#!/bin/bash

current_date=$(date +"%Y-%m-%d_%T")
wf-recorder --muxer=v4l2 --codec=libopenh264 --audio --file="~/Videos/Screencasts/Recording-$current_date.mp4" -g "$(slurp)"
