#!/bin/bash

#./iniParser.sh file.ini context
iniParser () {
	declare -a local OUT
	local sections=""
	local OUT=""
	local ITEM=""
	local ELEMENT=""
	local SES=""
	local VAR=""
	local FN=""
	local SPC="[ \t]"
	local ER_FN="^$SPC*\[(\w+)\].*"
	local ER_VAR="^$SPC*(\w+)(\[[0-9]\])?$SPC*=.*"
	local ini=""
	local IFS=$'\n' && ini=( $(<$1) )              # convert to line-array
	
	for ITEM in ${ini[@]}; do
		ITEM=`echo "$ITEM" | sed -r "s/\r|\n//g"`
		if [ "`echo "$ITEM" | egrep "$ER_FN"`" ]; then
			#echo "Context: $ITEM"
			if [ "$FN" ]; then OUT[${#OUT[*]} + 1]="}"; fi
			SES=`echo "$ITEM" | sed -r "s/$ER_FN/\\1/"`
			OUT[${#OUT[*]} + 1]="iniLoad.$2$SES (){"
			sections="${2}iniSections[\${#${2}iniSections[*]} + 1]=\"$2$SES\""
			eval "$(echo "$sections")"
			FN="1"
			VARIABLES=""
		else
			if [ "`echo "$ITEM" | egrep "$ER_VAR"`" ]; then
				VAR=`echo "$ITEM" | sed -r "s/$ER_VAR/\\1/"`
				if [ "`echo "$ITEM" | sed -r "s/$ER_VAR/\\2/"`" ]; then
					#echo "Line: $ITEM"
					if [ ! "`echo "$VAR" | egrep "^${VARIABLES[*]/ /|}$"`" ]; then
						OUT[${#OUT[*]} + 1]="  declare -a $2$VAR"
						OUT[${#OUT[*]} + 1]="  $2$VAR=''"
						VARIABLES[${#VARIABLES[*]} + 1]=$VAR
						#sections[${#sections[*]} + 1]="${2}iniSections_${SES}[\${#${2}iniSections_${SES}[*]]=\"$2$VAR\""
						sections="${2}iniSections_${SES}[\${#${2}iniSections_${SES}[*]} + 1]=\"$2$VAR\""
						eval "$(echo "$sections")"
					fi
				else
					#echo "xxxx: $ITEM"
					sections="${2}iniSections_${SES}[\${#${2}iniSections_${SES}[*]} + 1]=\"$2$VAR\""
					eval "$(echo "$sections")"
				fi
				VAR=`echo "$ITEM" | sed -r "s/^.*=$SPC*//"`
				if [ "${VAR:0:1}" == '"' ] || [ "${VAR:0:1}" == "'" ]; then
					VAR=`echo "$VAR" | sed -r "s/^\s*([\"'])(.*)\\1.*/\\2/"`
				else
					VAR="${VAR%;*}"
				fi
				OUT[${#OUT[*]} + 1]="  $2`echo "$ITEM" | sed -r "s/${ER_VAR[0]}/\\1\\2/"`=\"$VAR\""
			fi
		fi
	done
	OUT[${#OUT[*]} + 1]="}"
	#echo "${OUT[*]}"
	eval "$(echo "${OUT[*]}")"               # eval the result
}

if [ "$1" ] && [ -e "$1" ]; then
	iniParser "$1" "$2"
fi
