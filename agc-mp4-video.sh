#!/bin/sh

# (c)2019 Brian Sidebotham <brian.sidebotham@gmail.com>
# Author: Brian Sidebotham <brian.sidebotham@gmail.com>

if [ $# -ne 2 ]; then
    echo "usage: ${0} input.mp4 adjusted-output.mp4" >&2
    exit 1
fi

input="${1}"
output="${2}"

which ffmpeg > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "ffmpeg is required and hasn't been found!" >&2
    exit 1
fi

# Because I'm hard of hearing (not literally, but the dynamic range on these movies makes it impossible to listen to
# them at a normal volume!) we apply an automatic gain control to bring up the low level sounds and compress the high
# level sounds.
ffmpeg -i "${input}" -af 'compand=0|0:1|1:-90/-900|-70/-70|-30/-9|0/-3:6:0:0:0' -c:v copy -c:a aac -b:a 192k "${output}"
