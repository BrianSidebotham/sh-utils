#!/bin/sh

HandBrakeCLI --version > /dev/null 2>&1

if [ $? -ne 0 ]; then
    printf "%s" "HandBrakeCLI is required. Go to https://handbrake.fr to download it for your platform" >&2
    exit 1
fi

if [ $# -lt 1 ]; then
    printf "%s\n" "$0 output_filename.mp4" >&2
    exit 1
fi

# Get the input arguments
output="$1"

handbrake_version=$(HandBrakeCLI --version 2>&1 | grep -E "HandBrake [0-9]+")
printf "%s\n" "Using ${handbrake_version}"

# Add to the options as required
handbrake_options=""

# Source of the video
# # TODO: Fill out more options
handbrake_options="${handbrake_options} --input /dev/dvd"

# Track selection
# TODO: Fill out more options
handbrake_options="${handbrake_options} --main-feature"

# Encoders to use
# Video
handbrake_options="${handbrake_options} -ex264"
#handbrake_options="${handbrake_options} -ex264_10bit"
#handbrake_options="${handbrake_options} -ex265"
#handbrake_options="${handbrake_options} -ex265_10bit"
#handbrake_options="${handbrake_options} -ex265_12bit"
#handbrake_options="${handbrake_options} -empeg4"
#handbrake_options="${handbrake_options} -empeg2"
#handbrake_options="${handbrake_options} -eVP8"
#handbrake_options="${handbrake_options} -eVP9"
#handbrake_options="${handbrake_options} -etheora"

# Video quality - either constant quality or bitrate...
#handbrake_options="${handbrake_options} -b 1000" # (Default)
#handbrake_options="${handbrake_options} -b 2000"
handbrake_options="${handbrake_options} -b 3000"

# No idea what the quality settings look like - I only ever use fixed bit rate above.
#handbrake_options="${handbrake_options} -quality 17.0"
#handbrake_options="${handbrake_options} -quality 18.0"
#handbrake_options="${handbrake_options} -quality 19.0"
#handbrake_options="${handbrake_options} -quality 20.0"
#handbrake_options="${handbrake_options} -quality 21.0"
#handbrake_options="${handbrake_options} -quality 22.0"
#handbrake_options="${handbrake_options} -quality 23.0"


# Audio encoding
handbrake_options="${handbrake_options} -Eav_aac"
#handbrake_options="${handbrake_options} -Ecopy:aac"
#handbrake_options="${handbrake_options} -Eac3"
#handbrake_options="${handbrake_options} -Ecopy:ac3"
#handbrake_options="${handbrake_options} -Eeac3"
#handbrake_options="${handbrake_options} -Ecopy:eac3"
#handbrake_options="${handbrake_options} -Ecopy:truehd"
#handbrake_options="${handbrake_options} -Ecopy:dts"
#handbrake_options="${handbrake_options} -Ecopy:dtshd"
#handbrake_options="${handbrake_options} -Emp3"
#handbrake_options="${handbrake_options} -Ecopy:mp3"
#handbrake_options="${handbrake_options} -Evorbis"
#handbrake_options="${handbrake_options} -Eflac16"
#handbrake_options="${handbrake_options} -Eflac24"
#handbrake_options="${handbrake_options} -Ecopy:flac"
#handbrake_options="${handbrake_options} -Eopus"
#handbrake_options="${handbrake_options} -Ecopy"

# Audio Quality
# handbrake_options="${handbrake_options} -B 128"
handbrake_options="${handbrake_options} -B 192"

# Use subtitles when they're forced
handbrake_options="${handbrake_options} --subtitle-forced"


# Two pass mode or not?
#handbrake_options="${handbrake_options} --two-pass"
handbrake_options="${handbrake_options} --no-two-pass"

command="HandBrakeCLI ${handbrake_options} -o \"${output}\""

printf "%s\n" "Using command: ${command}"

${command}
