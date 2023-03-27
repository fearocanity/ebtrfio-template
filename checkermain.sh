#!/bin/bash

# check if all req. was provided in your repository for preparing frames to avoid errors

graph_url_main="https://graph.facebook.com"
token="${1}"
gif_token="${2}"

[[ -e ./config.conf ]] && . ./config.conf

format_noerr(){ printf '$\\fbox{\\colorbox{#DAFAE2}{\\color{#126329}\\textsf{\\normalsize  \\&#x2611; \\kern{0.2cm}\\small  %s  }}}$' "${*}" ;}
format_err(){ printf '$\\fbox{\\colorbox{#FFEBEA}{\\color{#82061E}\\textsf{\\normalsize  \\&#x26A0; \\kern{0.2cm}\\small  %s  }}}$' "${*}" ;} 
format_table(){ printf '| \x60%s\x60 | %s |\n' "${1}" "${2}" ;}

# Append Header
printf '<h1 align="center">%s</h1>\n<p align="center">%s</p>\n<div align="center">\n' "Repo Check" "This is where you can check whether it's all prepared or not"
printf '\n\n| %s | %s |\n| ---- | ---- |\n' "Variable/Object" "State"

checkif(){
	for i; do
		c="$(printf '\x24{%s}' "${i}")"
		x="$(eval "printf '%s' \"${c}\"")"
		if [[ -z "${x}" ]]; then
			format_table "${i}" "$(format_err "Variable is empty")" && err_state="1"
			printf '\e[31mERROR\e[0m - %s\n' "Variable is empty" >&2
		else
			format_table "${i}" "$(format_noerr "Passed")"
		fi
		unset c x
	done
}

sub_check(){
	if [[ "${sub_posting}" = "1" ]]; then
		if [[ -z "${subtitle_file}" ]]; then
			format_table "subtitle_file" "$(format_err "Variable is empty")" && err_state="1"
			printf '\e[31mERROR\e[0m - %s\n' "Variable is empty" >&2
		elif [[ ! -e "${subtitle_file}" ]]; then
			format_table "subtitle_file" "$(format_err "File not found")" "subtitle_file" && err_state="1"
			printf '\e[31mERROR\e[0m - %s\n' "File not found" >&2
		elif [[ -z "$(<./fb/"${subtitle_file}")" ]]; then
			format_table "subtitle_file" "$(format_err "File not found")" && err_state="1"
			printf '\e[31mERROR\e[0m - %s\n' "File not found" >&2
		else
			format_table "subtitle_file" "$(format_noerr "Passed")"
		fi
	fi
}

frames_check(){
	frame_number="$(find frames/frame_* 2>/dev/null | wc -l)"
	if [[ ! -d frames ]]; then
		format_table "frames" "$(format_err "Frames directory not found")" && err_state="1"
		printf '\e[31mERROR\e[0m - %s\n' "Frames directory not found" >&2
	elif [[ "${frame_number}" -lt 1 ]]; then
		format_table "frames" "$(format_err "No frames available")" && err_state="1"
		printf '\e[31mERROR\e[0m - %s\n' "No frames available" >&2
	else
		format_table "frames" "$(format_noerr "Total Frames: ${frame_number}")"
	fi
	if ! [[ -e fb/frameiterator ]]; then
		format_table "frameiterator" "$(format_err "File not found")" && err_state="1"
		printf '\e[31mERROR\e[0m - %s\n' "File not found" >&2
	elif grep -vEq '^[0-9]*$' fb/frameiterator; then
		format_table "frameiterator" "$(format_err "Invalid format")" && err_state="1"
		printf '\e[31mERROR\e[0m - %s\n' "Invalid format" >&2
	else
		format_table "frameiterator" "$(format_noerr "Valid format")"
	fi
}

token_check(){
	if curl -sLf -X HEAD "${graph_url_main}/me?access_token=${1}" -o /dev/null; then
		format_table "fb_token" "$(format_noerr "Token is Working")"
	else
		format_table "fb_token" "$(format_err "An error occured")" && err_state="1"
		printf '\e[31mERROR\e[0m - %s\n' "An error occured" >&2
	fi
	if [[ "${gif_post}" = "1" ]]; then
		if curl -sLf -X HEAD "https://api.giphy.com/v1/gifs/trending?api_key=${2}" -o /dev/null; then
			format_table "gif_token" "$(format_noerr "Token is Working")"
		else
			format_table "gif_token" "$(format_err "An error occured")" && err_state="1"
			printf '\e[31mERROR\e[0m - %s\n' "An error occured" >&2
		fi
	fi
}

checkif season episode total_frame fph mins delay_action
sub_check
frames_check
token_check "${token}" "${gif_token}"
printf '\n</div>'
[[ "${err_state}" = "1" ]] && exit 1
