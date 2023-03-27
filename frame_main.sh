#!/bin/bash

# Import config.conf
[[ -e ./config.conf ]] && . ./config.conf
[[ -e status/status.jpg ]] && : > status/status.jpg

prev_frame="$(<./fb/frameiterator)"
time_started="$(TZ='Asia/Tokyo' date)"

# Main Loop
for ((i=1;i<=fph;i++)); do
    bash ./frameposter.sh "${1}" "${2}" || bash img_process.sh "failed" "${time_started}" || exit 1
    sleep "$((mins * 60))"
done

lim_frame="$((prev_frame+fph-1))"
[[ "${lim_frame}" -gt "${total_frame}" ]] && lim_frame="${total_frame}"
[[ "${prev_frame}" -gt "${total_frame}" ]] && prev_frame="${total_frame}"

time_ended="$(TZ='Asia/Tokyo' date)"
bash img_process.sh "success" "${prev_frame}" "${lim_frame}" "${time_started}" "${time_ended}"
