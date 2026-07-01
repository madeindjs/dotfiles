#!/usr/bin/env bash
set -euo pipefail

help() {
  echo "Usage: $(basename "$0") <export-directory>" >&2
}

EXPORT_DIR="${1:-}"
JOBS_FILE=$(mktemp "music-library-export.XXXXX")
trap 'rm -f "$JOBS_FILE"' EXIT

echo "tasks created in $JOBS_FILE"

if [ -z "$EXPORT_DIR" ]; then
  help
  echo "You must provide the export directory" >&2
  exit 1
fi

# create the export folder if not exists
mkdir -p "$EXPORT_DIR" 2>/dev/null

function get_out_directory() {
  music_directory=$(dirname "$1")
  path="$EXPORT_DIR/${music_directory/./}"
  mkdir -p "$path"
  echo "$path"
}

function convert_file() {
  path=$(get_out_directory "$1")
  filename="$(basename "$1")"
  new_file="$path/${filename%.*}.mp3"

  if [ -f "$new_file" ]; then
    echo "skipping already converted file: $new_file" >&2
    return
  fi

  # -q:a 2: high-quality LAME VBR encoding (~190 kbps average, transparent for most listening)
  echo "ffmpeg -i '$1' -q:a 2 '$new_file'" >>"$JOBS_FILE"
}

function copy_file() {
  path=$(get_out_directory "$1")
  new_file="$path/$(basename "$1")"

  if [ -f "$new_file" ]; then
    echo "skipping already copied file: $new_file" >&2
    return
  fi

  echo "cp '$1' '$new_file'" >>"$JOBS_FILE"
}

find . -type f -print0 | while read -r -d $'\0' FILE; do
  case "${FILE,,}" in
    *.wav|*.flac|*.alac|*.aiff|*.aac|*.m4a|*.ogg|*.opus|*.wma|*.mp4|*.webm)
      convert_file "$FILE"
      ;;
    *.mp3)
      copy_file "$FILE"
      ;;
    *)
      echo "skipping non-audio file: $FILE" >&2
      ;;
  esac
done

parallel --bar <"$JOBS_FILE"
