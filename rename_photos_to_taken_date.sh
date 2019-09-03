#!/bin/sh

# (c)2018 Brian Sidebotham <brian.sidebotham@gmail.com>

scriptdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# We require a folder of pictures in order to rename them
if [ $# -ne 1 ]; then
    echo "usage: $0 path" >&2
    exit 1
fi

path=${1}

which exiftool > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: You need exiftool installed for this to work" >&2
    exit 1
fi

files=$(ls -1 ${path})

while IFS= read -r file; do
    create_date=$(exiftool -p '$CreateDate' "${path}/${file}" | tr ' ' ':' | tr -d ':')
    if [ $? -ne 0 ]; then
        echo "ERROR: Cannot rename file ${file}" >&2
        continue
    fi

    if [ "${create_date}X" = "X" ]; then
        echo "ERROR: No rename information for ${file}" >&2
        continue
    fi

    echo "FILE: ${file}: ${create_date}"
    mv "${path}/${file}" "${path}/${create_date}.jpg"
done << EOF
${files}
EOF
