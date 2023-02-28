#!/bin/bash
prev_frame="$(<./fb/frameiterator)"
[[ -e ./config.conf ]] && . ./config.conf
[[ -e status/status.jpg ]] && : > status/status.jpg

case "${1}" in
	in_progress)
		shift 1
		time_started="$(TZ='Asia/Tokyo' date)"
		lim_frame="$((prev_frame+fph-1))"
		[[ "${lim_frame}" -gt "${total_frame}" ]] && lim_frame="${total_frame}"
		convert -fill white -background "#a26b03" -gravity center -pointsize 72 -font "trebuc.ttf" label:"\ [~] Frame ${prev_frame}-${lim_frame} was currently posting in progress " -pointsize 25 label:"Time started: ${time_started}" -append -bordercolor "#a26b03" -border 30 status/status.jpg
		;;
	failed)
		shift 1
		lim_frame="$((prev_frame+fph-1))"
		[[ "${lim_frame}" -gt "${total_frame}" ]] && lim_frame="${total_frame}"
		convert -fill white -background "darkred" -gravity center -pointsize 72 -font "trebuc.ttf" label:"\ [X] Frame ${prev_frame}-${lim_frame} failed to post! " -pointsize 25 label:"Time started: ${1}" -append -bordercolor "darkred" -border 30 status/status.jpg
		exit 1
		;;
	success)
		shift 1
		convert -fill white -background "darkgreen" -gravity center -pointsize 72 -font "trebuc.ttf" label:"\ [√] Frame ${1}-${2} was posted " -pointsize 25 label:"Time started: ${3}\nTime ended: ${4}" -append -bordercolor "darkgreen" -border 30 status/status.jpg
		;;
esac