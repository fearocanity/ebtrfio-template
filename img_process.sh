#!/bin/bash
. config.conf
prev_frame="$(<"${FRMENV_ITER_FILE}")"
[[ -e status/status.jpg ]] && : > status/status.jpg

temp_cleanup(){
	rm status/output.png status/output1.png
}

create_image(){
	theme="${4}"
	percentage="$((${1} * 100 / ${3}))"
	percentage_end="$((${2} * 100 / ${3}))"
	width="350"
	progress_width="$(((width * percentage / 100) - 10))"
	progress_width_end="$(((width * percentage_end / 100) - 10))"
 
	[[ "${8}" = "true" ]] && percentage="${percentage_end}"
 
	convert -size "${width}x40" xc:none \
		-stroke "#373737" -strokewidth 2 \
		-fill "#2F2F2F" -draw "roundrectangle 10,10,$((width-10)),20,5,5" \
		-stroke none \
		-fill "${6}" -draw "roundrectangle 10,10,${progress_width_end},20,5,5" \
		-fill "${theme}" -draw "roundrectangle 10,10,${progress_width},20,5,5" \
		status/output.png

	convert -size 500x200 xc:none \
		-stroke "${theme}" -strokewidth 2 \
		-fill "#333333" -draw "roundrectangle 10,10,490,190,40,40" \
		-gravity west \
		-stroke none \
		\( status/output.png \
			-geometry +85+25 \
		\) -composite \
		-gravity center \
		-fill "#FFFFFF" -font status/fonts/mona_b.ttf -pointsize 35 -annotate +0-45 "${5}" \
		-font status/fonts/mona_bb.ttf -pointsize 18 -interline-spacing "5" -annotate +0-10 "Frame: ${1}-${2}" \
		-font status/fonts/mona_bb.ttf -pointsize 12 -interline-spacing "5" -annotate -180+21 "${percentage}%" \
		-font status/fonts/mona_bb.ttf -pointsize 10 -interline-spacing "5" -annotate -0+57 "${7}" \
		status/output1.png

	convert status/output1.png \
		\( +clone \
			-background "${theme}" \
			-shadow 50x50+0+0 \
		\) +swap \
		-background none \
		-layers merge \
		+repage status/status.png
}

case "${1}" in
	in_progress)
		shift 1
		time_started="$(TZ="${FRMENV_SYS_TIMEZONE}" date)"
		lim_frame="$((prev_frame+fph-1))"
		[[ "${lim_frame}" -gt "${total_frame}" ]] && lim_frame="${total_frame}"
		create_image "${prev_frame}" "${lim_frame}" "${total_frame}" "#a26b03" "Posting in Progress..." "#565656" "Time started: ${time_started}"
		;;
	failed)
		shift 1
		lim_frame="$((prev_frame+fph-1))"
		[[ "${lim_frame}" -gt "${total_frame}" ]] && lim_frame="${total_frame}"
		create_image "${prev_frame}" "${lim_frame}" "${total_frame}" "darkred" "Failed to Post..." "#565656" "Time started: ${1}"
		exit 1
		;;
	success)
		shift 1
		create_image "${1}" "${2}" "${total_frame}" "darkgreen" "Successfully Posted..." "darkgreen" "Time started: ${3}\nTime ended: ${4}" "true"
		;;
esac

temp_cleanup || true
