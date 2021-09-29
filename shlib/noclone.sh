#!/bin/bash

# /data/shared/shlib/noclone.sh --help
# /data/shared/shlib/noclone.sh -m /tmp -tzsPF
# /data/shared/shlib/noclone.sh -i /home/helbert.fernandes/Documents/noclone.csv -tzsPF 
#THIS_PATH=`dirname "$0"`
RECURSIVE=1;DELETE=0;FORCE_QUITE=0;EXEC_ACTION=0;COMPRESS=1;QUITE='';CHOICE_PATH=''
INFO_FILE='';MOVE_PATH='';TMP_FILE=''
TOTAL_FILES=0;DUPLICATED_COUNT=0;SHOW_VARS=0
PATHS=()

show_text(){
	[[ $QUITE = 0 ]] && echo "$@"
}
replace_text(){
	[[ $QUITE = 0 ]] && echo -n -e "\r\033[K$@"
}
move_file(){
	show_text "move $1"
	if [[ $EXEC_ACTION = 0 ]]; then
		echo "tar -rpf '$MOVE_PATH' '$1' 2> /dev/null; rm -f '${1}'"
	else
		tar -rpf "$MOVE_PATH" "$1" 2> /dev/null
		rm -f "$1"
	fi
}
remove_file(){
	show_text "remove $1"
	if [[ $EXEC_ACTION = 0 ]]; then
		echo "rm -f '$1'"
	else
		rm -f "$1" 
	fi
}
do_action(){
	local LINE=0;local CONT=0;local DUPLIC=0
	local THIS_KEY='';local OLD_KEY='';local FN=''
	local MIME;local HASH;local SIZE;local LEN_PATH;local LEN_FILE;local SYMBOLIC_LINK;local P;local F;local FULL_FILENAME
	local DUPLICATED_FILES=()
	while IFS=$'\t' read MIME HASH SIZE LEN_PATH LEN_FILE SYMBOLIC_LINK P F; do
		FULL_FILENAME="$P/$F"
		replace_text "Comparing $(echo "scale=2;100*$LINE/$TOTAL_FILES" | bc)% ($LINE/$TOTAL_FILES), ${#DUPLICATED_FILES[@]} to action"
		THIS_KEY="$MIME$HASH$SIZE"
		if [ "$THIS_KEY" = "$OLD_KEY" ]; then
			CONT=$((CONT+1))
			DUPLIC=1
			sed -ri "${LINE}s/0\$/1/" "$TMP_FILE"
		else
			CONT=0
			DUPLIC=0
			[[ $LINE != 0 ]] && sed -ri "${LINE}s/\t1\$/\$\t1/" "$TMP_FILE"
		fi
		LINE=$((LINE+1))
		sed -ri "${LINE}s/\$/\t$CONT\t$DUPLIC/" "$TMP_FILE"
		[[ $DUPLIC == 1 ]] && DUPLICATED_FILES[${#DUPLICATED_FILES[@]}]="$FULL_FILENAME"
		OLD_KEY="$THIS_KEY"
	done <"$TMP_FILE"
	DUPLICATED_COUNT=$(sed -nr '/1$/p' "$TMP_FILE" | wc -l)
	replace_text "Compared $DUPLICATED_COUNT files duplicated, ${#DUPLICATED_FILES[@]} to action"; show_text
	
	if [ "$MOVE_PATH" ]; then FN='move_file'
	elif [[ $DELETE == 1 ]]; then FN='remove_file'
	else FN='show_text rm -f '
	fi
	for FULL_FILENAME in ${DUPLICATED_FILES[@]};do $FN "$FULL_FILENAME"; done
}
order_list(){
	replace_text 'Sorting'
	local KEYS=(-k1,1f -k2,2f -k3,3n)
	local ITEM
	local V="$CHOICE_PATH"
	while [ "$V" ]; do
		ITEM=''
		case "${V:0:1}" in # zspf
			z) ITEM='-k4,4n';;
			Z) ITEM='-k4,4nr';;
			s) ITEM='-k5,5n';;
			S) ITEM='-k5,5nr';;
			p) ITEM='-k6,6f';;
			P) ITEM='-k6,6fr';;
			f) ITEM='-k7,7f';;
			F) ITEM='-k7,7fr';;
		esac
		KEYS[${#KEYS[@]}]="$ITEM"
		V="${V:1}"
	done
	sort -t$'\t' ${KEYS[@]} --output="$TMP_FILE" "$TMP_FILE"
	replace_text 'Sorted'; show_text
}
list_files(){
	local IFS_OLD="$IFS"
	local P="$1"
	local i
	local F
	local CONT=0
	local SUBDIR=()
	local TOTAL=$(find "$P" -type f -maxdepth 1 -not -name '.*' 2> /dev/null | wc -l)
	IFS=$'\n' && for i in $(ls -1 "$P"); do
		F="$P/$i"
		if [ -d "$F" ]; then 
			[ ! -h "$F" ] && [[ $RECURSIVE = 1 ]] && SUBDIR[${#SUBDIR[@]}]="$F"
		elif [ -f "$F" ]; then
			CONT=$((CONT+1))
			replace_text "Checking: $P/$i ($CONT/$TOTAL files)"
			echo -e "$(file -b --mime "$F")\t$(md5sum "$F" | cut -d' ' -f1)\t$(stat --format=%s "$F")\t${#P}\t${#i}\t$([ -h "$F" ] && echo 1 || echo 0)\t$P\t$i" >> "$TMP_FILE"
		fi
	done
	TOTAL_FILES=$((TOTAL_FILES+CONT))
	replace_text "Checked: $P ($CONT files)"; show_text
	for F in ${SUBDIR[@]}; do list_files "$F"; done
	IFS="$IFS_OLD"
}
normalize_path(){
	local P="$1"
	local O=''
	[ "${P:0:1}" != '/' ] && P="$(pwd)/$P"
	echo $(readlink -m "$P")
}
build(){
	TMP_FILE=$(mktemp)
	echo "${PATHS[@]}"
	for i in ${PATHS[@]}; do list_files "$i"; done
	show_text "$TOTAL_FILES files checked"
	order_list
	do_action

	sed -i "1i#MIME(type; encoding)\tHASH MD5\tSIZE\tLEN PATH\tLEN FILE\tSYMBOLIC LINK\tPATH\tFILE\tORDER\tDUPLICATED" "$TMP_FILE"
	if [ "$INFO_FILE" ]; then
		mkdir -p $(dirname "$INFO_FILE")
		mv -f "$TMP_FILE" "$INFO_FILE"
		[ "$MOVE_PATH" ] && tar -rf "$MOVE_PATH" "$INFO_FILE" 2> /dev/null
	else
		if [ "$MOVE_PATH" ]; then
			local DIR_TMP=$(dirname "$TMP_FILE")
			local NEW_NAME='noclone_report.csv'
			local NEW_FULLNAME="$DIR_TMP/$NEW_NAME"
			mv "$TMP_FILE" "$NEW_FULLNAME"
			TMP_FILE="$NEW_FULLNAME"
			tar -rf "$MOVE_PATH" -C "$DIR_TMP" "$NEW_NAME" 2> /dev/null
			[[ $COMPRESS == 1 ]] && show_text "Compress $MOVE_PATH" && bzip2 "$MOVE_PATH"
			[[ $FORCE_QUITE == 1 ]] && cat "$TMP_FILE"
		else
			cat "$TMP_FILE"
		fi
		rm -f "$TMP_FILE"
	fi
}
set_choice_path(){
	local V="$1"
	local ITEM="$1"
	while [ "$V" ]; do
		ITEM="${V:0:1}"
		[[ "$ITEM" == [zZsSpPfF] ]] && CHOICE_PATH="$(echo "$CHOICE_PATH" | sed -r "s/$ITEM//i")$ITEM"
		V="${V:1}"
	done
}
show_help(){
	echo "$0 [-m <mv_path>] [-i <inf_file>] [-t <[p|P][f|F]>] [-q|-q] [-f|-F] [-c|-C] [-r|-R] [-d|-D] [chk_path] [chk_path]"
	echo "  -q|-Q|--[no]quite        (-q=quite) ou (-Q=noQuite)"
	echo "  -f|-F|--[no]force_quite  (-f=force_quite) ou (-F=noForce_quite)[default]"
	echo "  -c|-C|--[no]compress     (-c=compress)[default] ou (-C=noCompress)"
	echo "  -r|-R|--[no]recursive    (-r=recursive)[default] Verifica Subpaths ou (-R=noRecursive) Não verifica Subpaths"
	echo "  -d|-D|--[no]delete       (-d=delete) Apaga ocorrências duplicadas ou (-D=noDelete)[default] Não apaga ocorrências duplicadas"
	echo "  -a|-A|--[no]exec_action  (-A=Exec_Action) Executa a ação de remover arquivos ou (-A=noExec_Action) [default] imprime a ação"
	echo "  -t<[p|P][s|S][f|F]>      Dá preferência para reter o primeiro da lista dos arquivos clones (Ex: -tp | -tzpsf):"
	echo "      z                         (size) tamanho da path"
	echo "      Z                         (Size) tamanho da path reverso"
	echo "      s                         (size) tamanho de nome de arquivo"
	echo "      S                         (Size) tamanho de nome de arquivo reverso"
	echo "      p                         (path) path em ordem crescente"
	echo "      P                         (Path) path em ordem decrescente"
	echo "      f                         (file) nome de arquivo em ordem crescente"
	echo "      F                         (File) nome de arquivo em ordem decrescente"
	echo "  -m mv_path               Move duplicados para path [default='']"
	echo "  -i inf_file              CSV TAB file to save informations of the collect [default=screen]"
	echo "  [chk_path]               Verifica path e sub-paths se é duplicado"
	echo "  -s|--show_vars           Apenas mostra as variaveis de configuração"
	echo
	echo "Ex:"
	echo "    $0 -m .                      -tzsPF /home/user/images /home/user/videos"
	echo "    $0 -m .        -i .          -tzsPF /home/user/images /home/user/videos"
	echo "    $0 -m .        -i report.csv -tzsPF /home/user/images /home/user/videos"
	echo "    $0 -m /var/tmp -i report.csv -tzsPF /home/user/images /home/user/videos"

	exit
}
start_opt(){
	local KEY
	local SUBKEY
	while [[ $# != 0 ]]; do
		SUBKEY="${1:2}"
		KEY="$1"; shift
		case "$KEY" in
			-r|--[rR]ecursive)			RECURSIVE=1;;
			-R|--no[rR]ecursive)		RECURSIVE=0;;
			-d|--[dD]elete)				DELETE=1;;
			-D|--no[dD]elete)			DELETE=0;;
			-q|--[qQ]uite)				QUITE=1;;
			-D|--no[qQ]uite)			QUITE=0;;
			-f|--[fF]orce_[qQ]uite)		FORCE_QUITE=1;;
			-F|--no[fF]orce_[qQ]uite)	FORCE_QUITE=0;;
			-c|--[cC]ompress)			COMPRESS=1;;
			-C|--no[cC]ompress)			COMPRESS=0;;
			-a|--[eE]xec_[aA]ction)		EXEC_ACTION=1;;
			-A|--no[eE]xec_[aA]ction)	EXEC_ACTION=1;;
			-s|--show_vars)             SHOW_VARS=1;;
			
			--help)				show_help;;
			*)
				[[ ${#SUBKEY} == 0 ]] && SUBKEY="$1" && shift
				case "$KEY" in
					-i*)	INFO_FILE="$SUBKEY"; [ ! "$QUITE" ] && QUITE=0;;
					-m*)	MOVE_PATH="$SUBKEY"; [ ! "$QUITE" ] && QUITE=0;;
					-t*)	set_choice_path "$SUBKEY";;
					*)		PATHS[${#PATHS[@]}]=$(readlink -m "$KEY");;
				esac;;
		esac
	done
	[ ! "$QUITE" ] && QUITE=1
	[[ ${#PATHS[@]} == 0 ]] && PATHS[0]=$(pwd)
	[ "$INFO_FILE" ] && INFO_FILE=$(normalize_path "$INFO_FILE")
	[ -d "$INFO_FILE" ] && INFO_FILE="$INFO_FILE/noclone_report.csv"
	if [ "$MOVE_PATH" ]; then
		MOVE_PATH=$(normalize_path "$MOVE_PATH")
		mkdir -p "$MOVE_PATH"
		MOVE_PATH="$MOVE_PATH/noclone_$(date +%Y%m%d%H%M%S).tar"
	fi
}
show_vars(){
	echo "RECURSIVE=${RECURSIVE}"
	echo "DELETE=${DELETE}"
	echo "FORCE_QUITE=${FORCE_QUITE}"
	echo "EXEC_ACTION=${EXEC_ACTION}"
	echo "COMPRESS=${COMPRESS}"
	echo "CHOICE_PATH=${CHOICE_PATH}"
	echo "INFO_FILE=${INFO_FILE}"
	echo "MOVE_PATH=${MOVE_PATH}"
	echo "TMP_FILE=${TMP_FILE}"
	echo "TOTAL_FILES=${TOTAL_FILES}"
	echo "DUPLICATED_COUNT=${DUPLICATED_COUNT}"
	echo "PATHS=${PATHS}"
	exit;
}
start_opt "$@"
[[ $SHOW_VARS = 1 ]] && show_vars
build
