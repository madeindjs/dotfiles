#!/usr/bin/env bash
set -euo pipefail

# take args
EXPORT_DIR="$1"
FORMAT="${2:-mp3}"
JOBS_FILE=$(mktemp "music-library-export.XXXXX")

echo "tasks created in $JOBS_FILE"

if [ -z "$EXPORT_DIR" ]; then
  help
  echo "You must provide the export directory" 1>&2
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
  new_file="$path/${filename%.*}.$2"

  echo "ffmpeg -i '$1' '$new_file'" >>"$JOBS_FILE"
}

function copy_file() {
  path=$(get_out_directory "$1")
  new_file="$path/$(basename "$1")"

  echo "cp '$1' '$new_file'" >>"$JOBS_FILE"
}

find . -type f -print0 | while read -r -d $'\0' FILE; do
  if [[ $FILE == *.wav ]] || [[ $FILE == *.flac ]] || [[ $FILE == *.alac ]]; then
    convert_file "$FILE" "$FORMAT"
  else
    copy_file "$FILE"
  fi
done

parallel --bar <"$JOBS_FILE"
