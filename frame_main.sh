#!/bin/bash

# Import config.conf
. config.conf
. scripts/post.sh
[[ -e status/status.jpg ]] && : > status/status.jpg

prev_frame="$(<"${FRMENV_ITER_FILE}")"
time_started="$(TZ="${FRMENV_SYS_TIMEZONE}" date)"

# Main Loop
for ((i=1;i<=fph;i++)); do
    bash ./main.sh "${1}" "${2}"
    error_code="$?"
    [[ "${error_code}" == 1 ]] && { bash img_process.sh "failed" "${time_started}" || exit 1 ;}
    [[ "${error_code}" == 12 ]] && exit 0
    sleep "$((mins * 60))"
done

lim_frame="$((prev_frame+fph-1))"
[[ "${lim_frame}" -gt "${total_frame}" ]] && lim_frame="${total_frame}"
[[ "${prev_frame}" -gt "${total_frame}" ]] && prev_frame="${total_frame}"

time_ended="$(TZ="${FRMENV_SYS_TIMEZONE}" date)"
if [[ "${desc_update}" == "1" ]]; then
    post_changedesc "${1}"
fi
bash img_process.sh "success" "${prev_frame}" "${lim_frame}" "${time_started}" "${time_ended}"
