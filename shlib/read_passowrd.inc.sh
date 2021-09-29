#!/bin/bash

#Modo de uso
#. /var/www/html/shared/shlib/read_passowrd.inc.sh
# SMB_DRIVER_PWD=`read_passowrd 'Password: '`; echo

read_passowrd(){
	local password=""
	local prompt="$1"
	local char=""
	local LEN=0
	
	while IFS= read -p "$prompt" -s -n 1 char; do
		if [[ $char == $'\0' ]]; then break; fi
		if [[ $char == $'\x08' ]]; then 
			LEN=${#password}
			if [[ $LEN > 0 ]]; then
				prompt="$char $char"
				password="${password:0:$LEN-1}"
			else
				prompt=""
			fi
		else
			prompt="*"
			password+="$char"
		fi
	done
	echo -n $password
}