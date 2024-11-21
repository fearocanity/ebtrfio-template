#!/bin/bash
# */
# Process task that was called in Main
# /*

process_creategif(){
	helper_depcheck convert | tee -a "${FRMENV_LOG_FILE}" || return 2
	[[ -e "${FRMENV_GIF_LOCATION}" ]] && rm "${FRMENV_GIF_LOCATION}"
	convert -resize "50%" -delay 20 -loop 1 $(eval "echo ${FRMENV_FRAME_LOCATION}/frame_{""${1}""..""${2}""}.jpg") "${FRMENV_GIF_LOCATION}"
	# GIPHY API is Required when using this code
	url_gif="$(curl -sLfX POST --retry 3 --retry-connrefused --retry-delay 7 -F "api_key=${FRMENV_GIFTOKEN}" -F "tags=${giphy_tags}" -F "file=@${FRMENV_GIF_LOCATION}" "${FRMENV_GIFAPI_ORIGIN}/v1/gifs" | sed -nE 's_.*"id":"([^\"]*)"\}.*_\1_p')"
	if [[ -z "${url_gif}" ]]; then
		return 1
	else
		printf '%s' "https://giphy.com/gifs/${url_gif}"
	fi
	unset url_gif
}

process_randomcrop(){
	[[ -e "${FRMENV_RC_LOCATION}" ]] && rm "${FRMENV_RC_LOCATION}"
	TEMP_CROP_WIDTH="$(helper_genrandrange "${rcrop_x}" "${rcrop_y}")"
	TEMP_CROP_HEIGHT="$(helper_genrandrange "${rcrop_x}" "${rcrop_y}")"
	TEMP_IMAGE_WIDTH="$(identify -format '%w' "${1}")"
	TEMP_IMAGE_HEIGHT="$(identify -format '%h' "${1}")"
	TEMP_CROP_X="$(($(helper_genrandnum) % (TEMP_IMAGE_WIDTH - TEMP_CROP_WIDTH)))"
	TEMP_CROP_Y="$(($(helper_genrandnum) % (TEMP_IMAGE_HEIGHT - TEMP_CROP_HEIGHT)))"
	convert "${1}" -crop "${TEMP_CROP_WIDTH}x${TEMP_CROP_HEIGHT}+${TEMP_CROP_X}+${TEMP_CROP_Y}" "${FRMENV_RC_LOCATION}"
	printf '%s' "Random Crop. [${TEMP_CROP_WIDTH}x${TEMP_CROP_HEIGHT} ~ X: ${TEMP_CROP_X}, Y: ${TEMP_CROP_Y}]"
	unset TEMP_CROP_WIDTH TEMP_CROP_HEIGHT TEMP_IMAGE_WIDTH TEMP_IMAGE_HEIGHT TEMP_CROP_X TEMP_CROP_Y
}

process_sectotime(){
	# This function aims to convert current frame to time (in seconds)
	helper_varchecker 'lack of information ("process_sectotime" function)' "${1}" "${frm_delay}" "${img_fps}"
	# This code below is standard, without tweaks.
	TEMP_SEC="$(bc -l <<< "scale=2; x = (${1} - ${frm_delay:-0}) / ${img_fps};"' if (length (x) == scale (x) && x != 0) { if (x < 0) print "-",0,-x else print 0,x } else print x')"
	if [[ "${2}" = "timestamp" ]] || grep -qE '^-' <<< "${sec}"; then
		TEMP_SEC="$(bc -l <<< "scale=2; x = ${1} / ${img_fps};"' if (length (x) == scale (x) && x != 0) { if (x < 0) print "-",0,-x else print 0,x } else print x')"
	fi
	TEMP_SECFLOAT="${TEMP_SEC#*.}" TEMP_SEC="${TEMP_SEC%.*}" TEMP_SEC="${TEMP_SEC:-0}"
	[[ "${TEMP_SECFLOAT}" =~ ^0[8-9]$ ]] && TEMP_SECFLOAT="${TEMP_SECFLOAT#0}"
	TEMP_SECFLOAT="${TEMP_SECFLOAT:-0}"
	printf '%01d:%02d:%02d.%02d' "$((TEMP_SEC / 60 / 60 % 60))" "$((TEMP_SEC / 60 % 60))" "$((TEMP_SEC % 60))" "${TEMP_SECFLOAT}"
	unset TEMP_SEC TEMP_SECFLOAT
}

process_subs(){
	# This function solves the timings of Subs
	# Set the current time variable
	TEMP_CURRENT_TIME="${1}"
	# Scrape the Subtitles (only supports srt & ass/ssa)
	if [[ "${2}" =~ \.srt$ ]]; then
		TEMP_MESSAGE_INIT="$(
			awk -v curr_time_sc="${TEMP_CURRENT_TIME}" -v RS="" '
			function m(t){
				gsub(/,/,".",t)
				split(t, a, ":")
				return a[1]*3600 + a[2]*60 + a[3]
			}
			{
				curr_time = m(curr_time_sc)
				start_time = m(substr($2, 1, 12))
				end_time = m(substr($4, 1, 12))
				if (curr_time >= start_time && curr_time <= end_time){
					gsub("\n", " ")
					gsub(/\r/, "")
					sub(/^[0-9]+\s[0-9:,]+ --> [0-9:,]+./, "")
					gsub(/<[^>]*>|<\/[^>]*>|{([^\x7d]*)}/, "")
					print $0
				}
			}' "${2}"
		)"
	elif [[ "${2}" =~ \.ass$|\.ssa$ ]]; then
		TEMP_MESSAGE_INIT="$(
			awk -F ',' -v curr_time_sc="${TEMP_CURRENT_TIME}" '
			function m(t){
				split(t, a, ":");
				return a[1]*3600 + a[2]*60 + a[3]
				delete a
			}
			/Dialogue:/ {
				curr_time = m(curr_time_sc)
				start_time = m($2)
				end_time = m($3)
				if (curr_time >= start_time && curr_time <= end_time) {
					c = $0;
					split(c, d, ",")
					split(c, e, ",,")
					f = d[4]","d[5]","
					g = (f ~ /[a-zA-Z0-9],,/) ? e[3] : e[2]
					gsub(/\r/,"",g)
					gsub(/   /," ",g)
					gsub(/!([a-zA-Z0-9])/,"! \\1",g)
					gsub(/(\\N{\\c&H727571&}|{\\c&HB2B5B2&})/,", ",g)
					gsub(/{([^\x7d]*)}/,"",g)
					if (g ~ /[[:graph:]]\\N/) gsub(/\\N/," ",g)
					gsub(/\\N/,"",g)
					gsub(/\\h/,"",g)
					if (f ~ /[^,]*,[Ss]ign/) {
						print "【"g"】"
					} else if (f ~ /[Ss]igns,,/) {
						print "\""g"\""
					} else if (f ~ /[Ss]ongs[^,]*,[^,]*,/) {
						print "『"g"』"
					} else {
						print g
					}
				}
			}' "${2}"
		)"
	else
		printf '%s\n' "failed to post subtitles, unsupported file type" >> "${FRMENV_LOG_FILE}"
	fi
	message_craft="$(awk '!a[$0]++{if ($0 ~ /^【.+】$/) aa=aa $0 "\n"; else bb=bb $0 "\n"} END {print aa bb}' <<< "${TEMP_MESSAGE_INIT}" | sed '/^[[:blank:]]*$/d;/^$/d')"
	[[ "${message_craft}" =~ ^『.*』$ ]] && BOOL_IS_OPEDSONG="1"
	unset TEMP_CURRENT_TIME TEMP_MESSAGE_INIT TEMP_MESSAGE_CRAFT
}

process_multisubs(){
	if ! declare -p "FRMENV_SUBS_FILE" | grep -qE -- '^declare -a'; then
		printf '%s\n' "Variable is not an array" >> "${FRMENV_LOG_FILE}"
		FRMENV_SUBS_FILE=("${FRMENV_SUBS_FILE}")
	fi
	for i in "${FRMENV_SUBS_FILE[@]}"; do
		[[ -e "${i}" ]] || continue
		[[ "${i}" =~ .*_([A-Za-z]{2})\.(srt|ass|ssa)$ ]] || continue
		process_subs "${1}" "${i}"
		[[ -z "${message_craft}" ]] && { unset message_craft BOOL_IS_OPEDSONG ; continue ;}
		if [[ "${BOOL_IS_OPEDSONG}" = "1" ]]; then
			message_comment+="Lyrics [$(sed -E 's/.*_([A-Za-z]{2})\.(srt|ass|ssa)$/\1/g' <<< "${i}" | tr '[:lower:]' '[:upper:]')]:"$'\n'"${message_craft}"$'\n'
		else
			message_comment+="Subtitles [$(sed -E 's/.*_([A-Za-z]{2})\.(srt|ass|ssa)$/\1/g' <<< "${i}" | tr '[:lower:]' '[:upper:]')]:"$'\n'"${message_craft}"$'\n'
		fi
		unset BOOL_IS_OPEDSONG
	done
	message_comment="$(sed '/^[[:blank:]]*$/d;/^$/d' <<< "${message_comment}")"
	[[ -z "${message_comment}" ]] && BOOL_IS_EMPTY="1" || BOOL_IS_EMPTY="0"
}
