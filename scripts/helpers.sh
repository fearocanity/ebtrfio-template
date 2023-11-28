#!/bin/bash
# */
# Helpers for processing, handling errors, checking dependencies
# /*

helper_statfailed(){
	if [[ "$#" -gt 2 ]]; then
		printf '%s\n' "[X] Frame: ${1}, Episode ${2}" >> "${FRMENV_LOG_FILE}"
		shift 2
	fi
	exit "${1}"
}

helper_depcheck(){
	for deppack; do
		if ! command -v "${deppack}" >/dev/null ; then
			printf '%s\n' "[FATAL ERROR] Program \"${deppack}\" is not installed."
			BOOL_IS_ERR="1"
		fi
	done
	if [[ "${BOOL_IS_ERR}" = "1" ]]; then
		unset BOOL_IS_ERR deppack
		return 1
	fi
	unset BOOL_IS_ERR deppack
	return 0
}

helper_genrandnum(){
	od -vAn -N2 -tu2 < /dev/urandom | tr -dc '0-9'
}

helper_genrandrange(){
	awk -v "a=${1}" -v "b=${2}" 'BEGIN{srand();print int(a+rand()*(b-a+1))}'
}

helper_varchecker(){
	TEMP_REASON="${1}"
	shift 1
	for i; do
		[[ -z "${i}" ]] && { printf '%s\n' "posting error: ${TEMP_REASON}" ; helper_statfailed 1 ;}
	done
	unset TEMP_REASON
}

