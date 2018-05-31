#!/bin/sh

# (c)2018 Brian Sidebotham <brian.sidebotham@gmail.com>

# Script to rename series files as Kodi requires a certain layout instead of being a bit more loose
# in its scraping of series and episode number information. The script will look for raw
# series-episode definitions in the filenames under the target path and rename those to be suitable
# for the Kodi scrapers which like the form S01E01

if [ $# -lt 1 ]; then
    echo "usage: $0 folder_of_series_files_to_rename" >&2
    exit 1
fi

target_path="$1"

# Get a list of filenames to iterate over. Don't bother trying to filter here. Let the regular
# expressions work out whether we should process or not.
filenames="$(ls -1 "${target_path}")"

# Loop over each filename (line)
echo "${filenames}" | while read line; do
    echo "Processing ${line}"
    # This could probably do with some explaining. The sed command doesn't need explaining, just go
    # look up what's going on with man sed, but the printf looks a bit odd. We want to keep the
    # series and episode numbers as 00 to 99 and the input is not guaranteed to have either
    # preceeding 0's or not.
    #
    # We printf in order to get the 00 to 99 range for both, but we must ensure that the input to
    # the printf command doesn't have leading 0's, otherwise it will get interpreted by printf as
    # an octal number.
    #
    # The parameter subsitution we do splits the parameter in textual terms at the last 0 and keeps
    # anything after it. This works for 01 to 09, but when there's a 0 at the end of the number
    # such as 10 or 20 we end up with an empty result, so we test for those cases and don't proceed
    # with the substitution in those cases.
    #
    series=$(echo "${line}" |  sed -n 's/\(.*\)\([0-9]\+\)-\([0-9]\+\)\(.*\)$/\2/p')

    if [ -z "${series}" ]; then
        echo "Could not process ${line}" >&2
        continue
    fi

    if [ -n "${series##*0}" ]; then
        series="${series##*0}"
    fi

    episode=$(echo "${line}" | sed -n 's/\(.*\)\([0-9]\+\)-\([0-9]\+\)\(.*\)$/\3/p')

    if [ -z "${episode}" ]; then
        echo "Could not process ${line}" >&2
        continue
    fi

    if [ -n "${episode##*0}" ]; then
        episode="${episode##*0}"
    fi

    prefix=$(echo "${line}" | sed -n 's/\(.*\)\([0-9]\+\)-\([0-9]\+\)\(.*\)$/\1/p')
    suffix=$(echo "${line}" | sed -n 's/\(.*\)\([0-9]\+\)-\([0-9]\+\)\(.*\)$/\4/p')

    target_filename=$(printf "%sS%02dE%02d%s" "${prefix}" "${series}" "${episode}" "${suffix}")

    mv -v "${target_path}/${line}" "${target_path}/${target_filename}"

done
