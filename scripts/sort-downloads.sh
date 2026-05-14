#!/bin/bash
set -uo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
[[ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ]] && source "$XDG_CONFIG_HOME/user-dirs.dirs"

DOWNLOADS="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
DOCUMENTS="${XDG_DOCUMENTS_DIR:-$HOME/Documents}"
PICTURES="${XDG_PICTURES_DIR:-$HOME/Pictures}"
VIDEOS="${XDG_VIDEOS_DIR:-$HOME/Videos}"
MUSIC="${XDG_MUSIC_DIR:-$HOME/Music}"

mkdir -p "$DOCUMENTS" "$PICTURES" "$VIDEOS" "$MUSIC"

LOCKFILE="/tmp/sort-downloads.lock"
exec 9>"$LOCKFILE"
flock -n 9 || exit 0

get_target() {
  local mime="$1" name="$2"
  case "$mime" in
    image/*) echo "$PICTURES" ;;
    video/*) echo "$VIDEOS" ;;
    audio/*) echo "$MUSIC" ;;
    application/pdf|application/epub+zip) echo "$DOCUMENTS" ;;
    text/plain|text/x-shellscript|text/markdown|text/html|text/x-c*|text/x-java*|text/x-python) echo "$DOCUMENTS" ;;
    text/xml|application/xml|application/json|application/x-tex) echo "$DOCUMENTS" ;;
    application/vnd.openxmlformats-officedocument.*|application/msword|application/vnd.ms-excel|application/vnd.ms-powerpoint|application/vnd.oasis.opendocument.*) echo "$DOCUMENTS" ;;
    inode/x-empty) echo "$DOCUMENTS" ;;
    application/octet-stream)
        case "${name,,}" in
          *.nbt|*.schem|*.litematic|*.bbmodel|*.imn|*.brM3) echo "$DOCUMENTS" ;;
        esac ;;
  esac
}

is_stable() {
  local f="$1"
  lsof "$f" 2>/dev/null | grep -qE ' [0-9]+[wu] ' && return 1
  local s1 s2
  s1=$(stat -c %s "$f" 2>/dev/null) || return 0
  sleep 1
  s2=$(stat -c %s "$f" 2>/dev/null) || return 0
  [[ "$s1" -eq "$s2" ]]
}

move_file() {
  local file="$1" target="$2"
  local filename="${file##*/}"
  local dest="$target/$filename" counter=1
  while [[ -e "$dest" ]]; do
    dest="$target/${filename%.*}_${counter}.${filename##*.}"
    ((counter++))
  done
  mv "$file" "$dest"
}

for file in "$DOWNLOADS"/*; do
  [[ -f "$file" ]] || continue
  filename="${file##*/}"
  [[ "$filename" == .* ]] && continue

  mime=$(file --mime-type -b "$file" 2>/dev/null || echo "unknown")
  target=$(get_target "$mime" "$filename")
  [[ -z "$target" ]] && continue

  # Wait up to ~30s for the file to be fully written
  waited=0
  while [[ $waited -lt 15 ]]; do
    is_stable "$file" && break
    sleep 2
    ((waited++))
  done

  move_file "$file" "$target"
done
