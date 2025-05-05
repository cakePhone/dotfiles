#!/bin/bash

hyprctl dispatch exec [float] "ghostty -e 'cd $(pwd) && $SHELL'"
