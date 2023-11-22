#!/bin/bash

# ############# #
# Author: EBTRFIO
# Date: Dec. 10 2022
# Licence: None
# Version: v1.6.0
# ############# #

# --- Dependencies --- #
# * bash
# * imgmagick (optional if GIF posting and Random Crop were enabled)
# * gnu sed
# * grep
# * curl
# * bc
# ############# #

# Initialize variable
: "${season:=}"
: "${episode:=}"
: "${total_frame:=}"
: "${img_fps:=}"

# Booleans Variables (Don't Modify if you don't know what you're doing)
: "${BOOL_IS_OPEDSONG:=0}"
: "${BOOL_IS_EMPTY:=1}"
: "${rand_post:=0}"
: "${gif_post:=0}"

# Import needed scripts
. secret.sh
. config.conf
. scripts/helpers.sh
. scripts/process.sh
. scripts/post.sh

# These token variables are required when making request and auths in APIs
# Create secret.sh file to assign the token variable
# (e.g)
# FRMENV_FBTOKEN="{your_api_key}"
# FRMENV_GIFTOKEN="{your_api_key}"
#
# ###################### #
# or Supply Arguments in Github Workflows
# you must create your Environment Variables in Secrets
FRMENV_FBTOKEN="${1:-${FRMENV_FBTOKEN}}"
FRMENV_GIFTOKEN="${2:-${FRMENV_GIFTOKEN}}"

# Check all the dependencies if installed
helper_depcheck awk sed grep curl bc jq || failed 1

# Create DIRs and files for iterator and temps/logs
[[ -d ./fb ]] || mkdir ./fb
[[ -e "${FRMENV_ITER_FILE}" ]] || printf '%s' "1" > "${FRMENV_ITER_FILE}"
{ [[ -z "$(<"${FRMENV_ITER_FILE}")" ]] || [[ "$(<"${FRMENV_ITER_FILE}")" -lt 1 ]] ;} && printf '%s' "1" > "${FRMENV_ITER_FILE}"

[[ "${total_frame}" -lt "$(<"${FRMENV_ITER_FILE}")" ]] && exit 0

# Get the previous frame from a file that acts like an iterator
prev_frame="$(<"${FRMENV_ITER_FILE}")"

# Check if the frame was already posted
if [[ -e "${FRMENV_LOG_FILE}" ]] && grep -qE "\[√\] Frame: ${prev_frame}, Episode ${episode}" "${FRMENV_LOG_FILE}"; then
	next_frame="$((prev_frame+=1))"
	printf '%s' "${next_frame}" > ./fb/frameiterator
	exit 0
fi

# Check if the variables are filled up
helper_varchecker 'lack of basic information (message variable)' "${season}" "${episode}" "${total_frame}"

# get time-stamps
if [[ -n "${img_fps}" ]]; then
	frame_timestamp="$(process_sectotime "${prev_frame}" "timestamp")"
	# Call the Scraper of Subs
	if [[ "${sub_posting}" = "1" ]]; then
		frame_totime="$(process_sectotime "${prev_frame}")"
		if [[ "${multilingual_subs}" = "1" ]]; then
			process_multisubs "${frame_totime}"
		elif [[ -e "${FRMENV_SUBS_FILE}" ]] && [[ -n "$(<"${FRMENV_SUBS_FILE}")" ]]; then
			process_subs "${frame_totime}" "${FRMENV_SUBS_FILE}"
			[[ -z "${message_craft}" ]] && BOOL_IS_EMPTY="1" || BOOL_IS_EMPTY="0"
			# Compare if the Subs are OP/ED Songs or Not (only works on ass/ssa subtitles)
			if [[ "${BOOL_IS_OPEDSONG}" = "1" ]]; then
				message_comment="Lyrics:"$'\n'"${message_craft}"
			else
				message_comment="Subtitles:"$'\n'"${message_craft}"
			fi
		fi
	fi
fi

# Refer to config.conf
message="$(eval "printf '%s' \"$(sed -E 's_\{\\n\}_\n_g;s_(\{[^\x7d]*\})_\$\1_g' <<< "${message}"\")")"

# post it in the front page
post_id="$(post_fp "${prev_frame}" | grep -Po '(?=[0-9])(.*)(?=\",\")')" || failed "${prev_frame}" "${episode}"

# Post images in Albums
[[ -z "${album}" ]] || post_album "${prev_frame}"

# Addons, Random Crop from frame
if [[ "${rand_post}" = "1" ]]; then
	sleep "${delay_action}" # Delay
	post_randomcrop "${prev_frame}" "${post_id}"
fi

# Comment the Subtitles on a post created on timeline
if [[ "${sub_posting}" = "1" ]]; then
	sleep "${delay_action}" # Delay
	[[ "${BOOL_IS_EMPTY}" = "1" ]] || post_subs "${post_id}"
fi

# Addons, GIF posting
if [[ "${gif_post}" = "1" ]]; then
	sleep "${delay_action}" # Delay
	[[ -n "${giphy_token}" ]] && [[ "${prev_frame}" -gt "${gif_prev_framecount}" ]] && post_gif "$((prev_frame - gif_prev_framecount))" "${prev_frame}" "${post_id}"
fi

# This will note that the Post was success, without errors and append it to log file
printf '%s %s\n' "[√] Frame: ${prev_frame}, Episode ${episode}" "https://facebook.com/${post_id}" >> "${FRMENV_LOG_FILE}"

# Lastly, This will increment prev_frame variable and redirect it to file
next_frame="$((prev_frame+=1))"
incmnt_cnt="$(($(<./counter_n.txt)+1))"
printf '%s' "${next_frame}" > "${FRMENV_ITER_FILE}"
printf '%s' "${incmnt_cnt}" > ./counter_n.txt

# Note:
# Please test it with development mode ON first before going to publish it, Publicly or (live mode)
# And i recommend using crontab as your scheduler