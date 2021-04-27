#!/bin/sh

# (c)2018 Brian Sidebotham <brian.sidebotham@gmail.com>

scriptdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ $# -lt 2 ]; then
    printf "%s\n" "$0 start_track number_of_tracks episode_start output_filename_base" >&2
    printf "%s\n" "  e.g. $0 3 6 7 FreshPrinceOfBelAirS03E"
    exit 1
fi

# Get the input arguments
start_track=${1}
number_of_tracks=${2}
episode_start=${3}
output_filename_base=${4}

current_track=${start_track}
end_track=$(( ${start_track} + ${number_of_tracks} ))

printf "%s\n" "Ripping tracks ${current_track} to ${end_track}"

while [ ${current_track} -lt ${end_track} ]; do
    printf "%s" "Ripping track ${current_track}"
    output_filename=$(printf "%s%02d\n" "${output_filename_base}" "$(( ${current_track} - ${start_track} + ${episode_start} ))")
    ${scriptdir}/rip-dvd-track.sh ${current_track} ${output_filename}
    current_track=$(( ${current_track} + 1 ))
done
