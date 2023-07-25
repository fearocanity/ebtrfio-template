#!/bin/bash

# Import config.conf
[[ -e ./config.conf ]] && . ./config.conf
[[ -e status/status.jpg ]] && : > status/status.jpg

prev_frame="$(<./fb/frameiterator)"
time_started="$(TZ="${sys_timezone}" date)"

# Main Loop
for ((i=1;i<=fph;i++)); do
    bash ./frameposter.sh "${1}" "${2}" || bash img_process.sh "failed" "${time_started}" || exit 1
    sleep "$((mins * 60))"
done

lim_frame="$((prev_frame+fph-1))"
[[ "${lim_frame}" -gt "${total_frame}" ]] && lim_frame="${total_frame}"
[[ "${prev_frame}" -gt "${total_frame}" ]] && prev_frame="${total_frame}"

time_ended="$(TZ="${sys_timezone}" date)"
if [[ "${desc_update}" == "1" ]]; then
    ovr_all="$(sed -E ':L;s=\b([0-9]+)([0-9]{3})\b=\1,\2=g;t L' counter_n.txt)"
    abt_txt="$(eval "printf '%s' \"$(sed -E 's_\{\\n\}_\n_g;s_\{([^\x7d]*)\}_\${\1:-??}_g;s|ovr_all:-\?\?|over_all:-0|g' <<< "${abt_txt}"\")")"
    curl -sLk -X POST "https://graph.facebook.com/me/?access_token=${1}" --data-urlencode "about=${abt_txt}" -o /dev/null || true
fi
bash img_process.sh "success" "${prev_frame}" "${lim_frame}" "${time_started}" "${time_ended}"
