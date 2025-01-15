#!/bin/bash
# */
# This is where all the actions will happen
# /*

post_gif(){
	TEMP_GIFURL="$(process_creategif "${1}" "${2}")"
	TEMP_CRAFTMESSAGE="GIF created from last ${gif_prev_framecount} frames (${1}-${2})"
	curl -sfLX POST \
		-d "message=${TEMP_CRAFTMESSAGE}" \
		-d "attachment_share_url=${TEMP_GIFURL}" \
		-o /dev/null \
	"${FRMENV_API_ORIGIN}/${FRMENV_FBAPI_VER}/${3}/comments?access_token=${FRMENV_FBTOKEN}" || return 1
	unset TEMP_CRAFTMESSAGE
}

post_randomcrop(){
	TEMP_CRAFTMESSAGE="$(process_randomcrop "${FRMENV_FRAME_LOCATION}/frame_${1}.jpg")"
	curl -sfLX POST \
		--retry 2 \
		--retry-connrefused \
		--retry-delay 7 \
		-F "message=${TEMP_CRAFTMESSAGE}" \
		-F "source=@${FRMENV_RC_LOCATION}" \
		-o /dev/null \
	"${FRMENV_API_ORIGIN}/${FRMENV_FBAPI_VER}/${2}/comments?access_token=${FRMENV_FBTOKEN}" || return 1
	unset TEMP_CRAFTMESSAGE
}

post_fp(){
	curl -sfLX POST \
		--retry 2 \
		--retry-connrefused \
		--retry-delay 7 \
		-F "message=${message}" \
		-F "source=@${FRMENV_FRAME_LOCATION}/frame_${1}.jpg" \
	"${FRMENV_API_ORIGIN}/me/photos?access_token=${FRMENV_FBTOKEN}&published=1"
}

post_album(){
	curl -sfLX POST \
		--retry 2 \
		--retry-connrefused \
		--retry-delay 7 \
		-F "source=@${FRMENV_FRAME_LOCATION}/frame_${1}.jpg" \
		-F "message=${message}" \
		-o /dev/null \
	"${FRMENV_API_ORIGIN}/${album}/photos?access_token=${FRMENV_FBTOKEN}&published=1" || return 1
}

post_subs(){
	curl -sfLX POST \
		--retry 2 \
		--retry-connrefused \
		--retry-delay 7 \
		--data-urlencode "message=${message_comment}" \
		-o /dev/null \
	"${FRMENV_API_ORIGIN}/${FRMENV_FBAPI_VER}/${1}/comments?access_token=${FRMENV_FBTOKEN}" || return 1
}

post_changedesc(){
	ovr_all="$(sed -E ':L;s=\b([0-9]+)([0-9]{3})\b=\1,\2=g;t L' counter_total_frames.txt)"
	get_interval="$(sed -nE 's|.*posting_interval="([0-9]+)".*|\1|p' ./config.conf)"
	TEMP_ABT_TXT="$(eval "printf '%s' \"$(sed -E 's_\{\\n\}_\n_g;s_\{([^\x7d]*)\}_\${\1:-??}_g;s|ovr_all:-\?\?|ovr_all:-0|g' <<< "${abt_txt}"\")")"
	curl -sLk -X POST "${FRMENV_API_ORIGIN}/me/?access_token=${1}" --data-urlencode "about=${TEMP_ABT_TXT}" -o /dev/null || true
	unset TEMP_ABT_TXT 
}
