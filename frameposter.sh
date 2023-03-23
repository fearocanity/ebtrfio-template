#!/bin/bash

# ############# #
# Author: EBTRFIO
# Date: Dec. 10 2022
# Licence: None
# Version: v1.3.3
# ############# #

# --- Dependencies --- #
# * bash
# * imgmagick (optional if GIF posting were enabled)
# * gnu sed
# * grep
# * curl
# * bc
# ############# #
[[ -e ./secret.sh ]] && . ./secret.sh
[[ -e ./config.conf ]] && . ./config.conf
# Invi Space (Space that actually bypass the blank character stripper of facebook)
# 　　　　　　　
# ^^^ Invi Space ^^^

# export PATH="$PATH:/usr/bin:/usr/sbin"

# opt variables
graph_url_main="https://graph.facebook.com"
frames_location=./frames
log=./fb/log.txt
vidgif_location=./fb/tmp.gif
rc_location=./fb/tmprc.jpg
: "${season:=}"
: "${episode:=}"
: "${total_frame:=}"
: "${vid_fps:=}"
: "${vid_totalfrm:=}"

# Hardcoded Scrapings only Supported on ass subs by Erai Raws
locationsub=./fb/"${subtitle_file}"

# Booleans Variables (Don't Modify if you don't know what you're doing)
: "${rand_post:=0}"
: "${gif_post:=0}"
: "${is_empty:=1}"
: "${is_opedsong:=0}"

# These token variables are required when making request and auths in APIs
# Create secret.sh file to assign the token variable
# (e.g)
# fb_api_key="{your_api_key}"
# giphy_api_key="{your_api_key}"
#
# ###################### #
# or Supply Arguments in Github Workflows
# you must create your Environment Variables in Secrets
token="${1:-${fb_api_key}}"
giphy_token="${2:-${giphy_api_key}}"

failed(){
	[[ "$#" -gt 0 ]] && printf '%s\n' "[X] Frame: ${1}, Episode ${2}" >> "${log}"
	exit 1
}

dep_check(){
	for deppack; do
		if ! command -v "${deppack}" >/dev/null ; then
			printf '%s\n' "[FATAL ERROR] Program \"${deppack}\" is not installed."
			is_err="1"
		fi
	done
	[[ "${is_err}" = "1" ]] && return 1
	return 0
}

create_gif(){
	dep_check convert | tee -a "${log}" || return 1
	[[ -e "${vidgif_location}" ]] && rm "${vidgif_location}"
	convert -resize "50%" -delay 20 -loop 1 $(eval "echo ${frames_location}/frame_{""${1}""..""${2}""}.jpg") "${vidgif_location}"

	# GIPHY API is Required when using this code
	url_gif="$(curl -sLfX POST --retry 3 --retry-connrefused --retry-delay 7 -F "api_key=${giphy_token}" -F "tags=${giphy_tags}" -F "file=@${vidgif_location}" "https://upload.giphy.com/v1/gifs" | sed -nE 's_.*"id":"([^\"]*)"\}.*_\1_p')"
	[[ -z "${url_gif}" ]] && return 1 || url_gif="https://giphy.com/gifs/${url_gif}"

	curl -sfLX POST "${graph_url_main}/v16.0/${id}/comments?access_token=${token}" -d "message=GIF created from last 10 frames (${1}-${2})" -d "attachment_share_url=${url_gif}" -o /dev/null
}

rand_func(){ od -vAn -N2 -tu2 < /dev/urandom | tr -dc '0-9' ;}
rand_range(){ awk -v "a=100" -v "b=350" 'BEGIN{srand();print int(a+rand()*(b-a+1))}' ;}

random_crop(){
	[[ -e "${rc_location}" ]] && rm "${rc_location}"
	crop_width="$(rand_range)"
	crop_height="$(rand_range)"
	image_width="$(identify -format '%w' "${1}")"
	image_height="$(identify -format '%h' "${1}")"
	crop_x="$(($(rand_func) % (image_width - crop_width)))"
	crop_y="$(($(rand_func) % (image_height - crop_height)))"
	convert "${1}" -crop "${crop_width}x${crop_height}+${crop_x}+${crop_y}" "${rc_location}"
	msg_rc="Random Crop. [${crop_width}x${crop_height} ~ X: ${crop_x}, Y: ${crop_y}]"
	curl -sfLX POST --retry 2 --retry-connrefused --retry-delay 7 "${graph_url_main}/v16.0/${id}/comments?access_token=${token}" -F "message=${msg_rc}" -F "source=@${rc_location}" -o /dev/null
}

nth(){
	# This function aims to convert current frame to time (in seconds)
	#
	# You need to get the exact Frame Rate of a video
	t="${1/[!0-9]/}"
	# Old Formula: {current_frame} * ({2fps}/{frame_rate}) / {frame_rate} = {total_secs}
	# Note: Old formula is innaccurate
	#
	# New Formula: {current_frame} * ({vid_totalframe} / {total_frame}) / {frame_rate} = {total_secs}
	# Ex: (1532 - 1) * 7.98475609756 / 23.93 = 511.49
	for i in "${vid_totalfrm}" "${total_frame}" "${vid_fps}"; do
		[[ -z "${i}" ]] && { printf '%s\n' "posting error: lack of information (\"nth\" function)" ; failed ;} 
	done

	# This code below is standard, without tweaks.
	sec="$(bc -l <<< "scale=11; ${vid_totalfrm} / ${total_frame}")"
	sec="$(bc -l <<< "scale=2; (${t:-1} - ${frm_delay}) * ${sec} / ${vid_fps}")" secfloat="${sec#*.}" sec="${sec%.*}" sec="${sec:-0}"

	[[ "${secfloat}" =~ ^0[8-9]$ ]] && secfloat="${secfloat#0}"
	secfloat="${secfloat:-0}"
	printf '%01d:%02d:%02d.%02d' "$((sec / 60 / 60 % 60))" "$((sec / 60 % 60))" "$((sec % 60))" "${secfloat}"
	unset sec secfloat
}

scrv3(){
	# This function solves the timings of Subs
	# Set the current time variable
	current_time="${1}"
	# Scrape the Subtitles
	# This awk syntax is pretty much hardcoded but quite genius because all this scrapings are happening in only 2 awk commands, thats why the scrapings are 100x faster than the previous versions
	message_craft="$(
	awk -F ',' -v curr_time_sc="${current_time}" '/Dialogue:/ {
			split(curr_time_sc, aa, ":");
			curr_time = aa[1]*3600 + aa[2]*60 + aa[3];
			split($2, a, ":");
			start_time = a[1]*3600 + a[2]*60 + a[3];
			split($3, b, ":");
			end_time = b[1]*3600 + b[2]*60 + b[3];
			if (curr_time>=start_time && curr_time<=end_time) {
				c = $0;
				split(c, d, ",");
				split(c, e, ",,");
				f = d[4]","d[5]",";
				g = (f ~ /[a-zA-Z],,/) ? e[3] : e[2];
				gsub(/\r/,"",g);
				gsub(/   /," ",g);
				gsub(/!([a-zA-Z0-9])/,"! \\1",g);
				gsub(/(\\N{\\c&H727571&}|{\\c&HB2B5B2&})/,", ",g);
				gsub(/{([^\x7d]*)}/,"",g);
				if(g ~ /[[:graph:]]\\N/) gsub(/\\N/," ",g);
				gsub(/\\N/,"",g);
				gsub(/\\h/,"",g);
				if (f ~ /[^,]*,sign/) {
					print "【"g"】"
				} else if (f ~ /Signs,,/) {
					print "\""g"\""
				} else if (f ~ /Songs_OP,OP/ || f ~ /Songs_ED,ED/) {
					print "『"g"』"
				} else {
					print g
				}
			}
		}' "${locationsub}" | \
	awk '!a[$0]++{
			if ($0 ~ /^【.+】$/) aa=aa $0 "\n"; else bb=bb $0 "\n"
		} END {
		print aa bb
		}' | \
	sed '/^[[:blank:]]*$/d;/^$/d'
	)"
	[[ "${message_craft}" =~ ^『.*』$ ]] && is_opedsong="1"
	[[ -z "${message_craft}" ]] && is_empty="1" || is_empty="0"
	unset current_time
}


# Check all the dependencies if installed
dep_check awk sed grep curl bc || failed

# Create DIRs and files for iterator and temps/logs
[[ ! -d ./fb ]] && mkdir ./fb
[[ ! -e ./fb/frameiterator ]] && printf '%s' "1" > ./fb/frameiterator
{ [[ -z "$(<./fb/frameiterator)" ]] || [[ "$(<./fb/frameiterator)" -lt 1 ]] ;} && printf '%s' "1" > ./fb/frameiterator

[[ "${total_frame}" -lt "$(<./fb/frameiterator)" ]] && exit 0

# Get the previous frame from a file that acts like an iterator
prev_frame="$(<./fb/frameiterator)"

# Check if the frame was already posted
if [[ -e "${log}" ]] && grep -qE "\[√\] Frame: ${prev_frame}, Episode ${episode}" "${log}"; then
	next_frame="$((prev_frame+=1))"
	printf '%s' "${next_frame}" > ./fb/frameiterator
	exit 0
fi

# This is where you can change your post captions and own format (that one below is the default)
for i in "${season}" "${episode}" "${total_frame}"; do
		[[ -z "${i}" ]] && { printf '%s\n' "posting error: lack of information (message variable)" ; failed ;} 
done
message="Season ${season}, Episode ${episode}, Frame ${prev_frame} out of ${total_frame}"

# Call the Scraper of Subs
if [[ "${sub_posting}" = "1" ]] && [[ -e "${locationsub}" ]] && [[ -n "$(<"${locationsub}")" ]]; then
	scrv3 "$(nth "${prev_frame}")"
fi

# Compare if the Subs are OP/ED Songs or Not
if [[ "${is_opedsong}" = "1" ]]; then
	message_comment="Lyrics:
${message_craft}"
else
	message_comment="Subtitles:
${message_craft}"
fi

# Post images to Timeline of Page
response="$(curl -sfLX POST --retry 2 --retry-connrefused --retry-delay 7 "${graph_url_main}/me/photos?access_token=${token}&published=1" -F "message=${message}" -F "source=@${frames_location}/frame_${prev_frame}.jpg")" || failed "${prev_frame}" "${episode}"

# Get the ID of Image Post
id="$(printf '%s' "${response}" | grep -Po '(?=[0-9])(.*)(?=\",\")')"

sleep "${delay_action}" # Delay

# Post images in Albums
[[ -z "${album}" ]] || curl -sfLX POST --retry 2 --retry-connrefused --retry-delay 7 "${graph_url_main}/${album}/photos?access_token=${token}&published=1" -F "message=${message}" -F "source=@${frames_location}/frame_${prev_frame}.jpg" -o /dev/null

# Addons, Random Crop from frame
if [[ "${rand_post}" = "1" ]]; then
	sleep "${delay_action}" # Delay
	random_crop "${frames_location}/frame_${prev_frame}.jpg"
fi

# Comment the Subtitles on a post created on timeline
if [[ -e "${locationsub}" ]]; then
	sleep "${delay_action}" # Delay
	[[ "${is_empty}" = "1" ]] || curl -sfLX POST --retry 2 --retry-connrefused --retry-delay 7 "${graph_url_main}/v16.0/${id}/comments?access_token=${token}" --data-urlencode "message=${message_comment}" -o /dev/null
fi

# Addons, GIF posting
if [[ "${gif_post}" = "1" ]]; then
	sleep "${delay_action}" # Delay
	[[ -n "${giphy_token}" ]] && [[ "${prev_frame}" -gt "${gif_prev_framecount}" ]] && create_gif "$((prev_frame - gif_prev_framecount))" "${prev_frame}"
fi

# This will note that the Post was success, without errors and append it to log file
printf '%s %s\n' "[√] Frame: ${prev_frame}, Episode ${episode}" "https://facebook.com/${id}" >> "${log}"

# Lastly, This will increment prev_frame variable and redirect it to file
next_frame="$((prev_frame+=1))"
printf '%s' "${next_frame}" > ./fb/frameiterator


# Note:
# Please test it with development mode ON first before going to publish it, Publicly or (live mode)
# And i recommend using crontab as your scheduler
