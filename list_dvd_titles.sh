#!/bin/sh

# (c)2018 Brian Sidebotham <brian.sidebotham@gmail.com>

scriptdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

which HandBrakeCLI > /dev/null 2>&1

if [ $? -ne 0 ]; then
    printf "%s" "HandBrakeCLI is required. Go to https://handbrake.fr to download it for your platform" >&2
    exit 1
fi

HandBrakeCLI --input /dev/sr0 --title 0 2>&1 | grep -A2 '+ title'
