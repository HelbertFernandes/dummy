#!/bin/bash

DIR=${0%/*}
FILE=${0##*/}
cfg.parser () {
	local ini=""
	local OUT=""
	local ITEM=""
	local ELEMENT=""
	local VAR=""
	local VARIABLES=""
	local SEP=""
	local IFS=$'\n' && ini=( $(<$1) )              # convert to line-array
	declare -a OUT

	ini=( ${ini[*]//;*/} )                   # remove comments
	ini=( ${ini[*]/#[/\}$'\n'cfg.section.} ) # set section prefix
	ini=( ${ini[*]/%]/ \(} )                 # convert text2function (1)
	ini=( ${ini[*]/=/=\( } )                 # convert item to array
	ini=( ${ini[*]/%/ \)} )                  # close array parenthesis
	ini=( ${ini[*]/%\( \)/\(\) \{} )         # convert text2function (2)
	ini=( ${ini[*]/%\} \)/\}} )              # remove extra parenthesis
	for ELEMENT in ${!ini[@]}; do
		ITEM="${ini[$ELEMENT]}"
		if [ "$ITEM" ]; then
			if [ "`echo "$ITEM" | egrep "{\s*$"`" ]; then
				VARIABLES=""
			fi
			if [ "`echo "$ITEM" | egrep "^\w+\[[0-9]+\]"`" ]; then
				ITEM=${ITEM/=\( /=}
				ITEM=${ITEM%\)*}
				VAR=${ITEM%%[*}
				if [ "$VARIABLES" ]; then
					SEP="|"
				else
					SEP=""
				fi
				if [ ! "`echo "$VAR" | egrep "^$VARIABLES$"`" ]; then
					eval "declare -a $VAR"
					OUT[${#OUT[*]} + 1]="${VAR}=''"
					VARIABLES="$VARIABLES$SEP$VAR"
					echo "declare -a $VAR # $VARIABLES$SEP$VAR"
				fi
				
			fi
			OUT[${#OUT[*]} + 1]="$ITEM"
			
		fi
	done
	OUT[1]=''                                # remove first element
	OUT[${#OUT[*]} + 1]='}'                  # add the last brace
	#echo "${OUT[*]}"
	eval "$(echo "${OUT[*]}")"               # eval the result
}
