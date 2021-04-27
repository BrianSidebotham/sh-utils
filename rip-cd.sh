#!/bin/sh

scriptdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

which abcde > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Cannot find abcde3 which is required for " >&2
    exit 1
fi

ALBUMDIR="${1}"
ALBUMARTWORK="${2}"

echo "Using artwork ${ALBUMARTWORK}"

cddrive=$(cat /proc/sys/dev/cdrom/info | grep "drive name" | cut -d':' -f 2 | tr -d '[:blank:]')
if [ "${cddrive}X" = "X" ]; then
    echo "Cannot detect a CD drive under /proc/sys/dev/cdrom" >&2
    exit 1
fi

abcde -B -o mp3 -d /dev/${cddrive}
