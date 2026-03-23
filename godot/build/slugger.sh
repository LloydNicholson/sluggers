#!/bin/sh
printf '\033c\033]0;%s\a' Sluggers
base_path="$(dirname "$(realpath "$0")")"
"$base_path/slugger.x86_64" "$@"
