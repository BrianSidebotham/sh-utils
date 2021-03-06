#!/bin/sh

# (c)2018 Brian Sidebotham <brian.sidebotham@gmail.com>

scriptdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# On Fedora Core 31 you'll need to install HandBrake CLI and install the DVD Decryption library too:
#     dnf install HandBrake
# Go and download the libdvdcss rpm: https://fedora.pkgs.org/31/cheese-x86_64/libdvdcss-1.4.2-2.fc31.x86_64.rpm.html'
# Install it:
#     dnf install ~/Downloads/libdvdcss-1.4.2.fc31.x86_64.rpm

which HandBrakeCLI > /dev/null 2>&1

if [ $? -ne 0 ]; then
    printf "%s" "HandBrakeCLI is required. Go to https://handbrake.fr to download it for your platform" >&2
    printf "%s" "Fedora: dnf install -y handbrake && dnf install -y http://www.nosuchhost.net/~cheese/fedora/packages/33/x86_64/libdvdcss-1.4.2-2.fc33.x86_64.rpm" >&2
    exit 1
fi

if [ $# -lt 1 ]; then
    printf "%s\n" "$0 output_filename.mp4" >&2
    exit 1
fi

# Get the input arguments
output=$1

handbrake_version=$(HandBrakeCLI --version 2>&1 | grep -E "HandBrake [0-9]+")
printf "%s\n" "Using ${handbrake_version}"

# Add to the options as required
handbrake_options=""

# Source of the video
# # TODO: Fill out more options
dvddrive=$(cat /proc/sys/dev/cdrom/info | grep "drive name" | cut -d':' -f 2 | tr -d '[:blank:]')
if [ "${dvddrive}X" = "X" ]; then
    echo "Cannot detect a DVD drive under /proc/sys/dev/cdrom" >&2
    exit 1
fi

handbrake_options="${handbrake_options} --input /dev/${dvddrive}"

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

# Best to deinterlace of course!
handbrake_options="${handbrake_options} --deinterlace"

# Audio Quality
# handbrake_options="${handbrake_options} -B 128"
handbrake_options="${handbrake_options} -B 192"

# Language handbrake_options
handbrake_options="${handbrake_options} --native-language eng"
#handbrake_options="${handbrake_options} --native-language fre"

# Use the audio track that matches the native-language setting rather than the first audio track
handbrake_options="${handbrake_options} --native-dub"

# Apply dynamic compression of the audio to enable softer sounds being louder!
handbrake_options="${handbrake_options} --drc 2.5"
handbrake_options="${handbrake_options} --mixdown stereo"

# Use subtitles when they're forced
handbrake_options="${handbrake_options} --subtitle scan"
handbrake_options="${handbrake_options} --subtitle-forced"
handbrake_options="${handbrake_options} --subtitle-burned"

# Two pass mode or not?
#handbrake_options="${handbrake_options} --two-pass"
handbrake_options="${handbrake_options} --no-two-pass"

command="HandBrakeCLI ${handbrake_options}"

printf "%s\n" "Using command: ${command}"

${command} -o "${output}.mp4"

# Adjust the film's audio track to make sure we get a good copy of the audio that I can actually hear!
if [ -f ${scriptdir}/agc-mp4-video.sh ]; then
    ./agc-mp4-video.sh "${output}.mp4" "${output}-agc.mp4"
fi
