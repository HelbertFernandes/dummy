#!/bin/bash
THIS_PATH=`dirname "$0"`
INFO_FILE=''
MOVE_PATH=''
CHOICE_PATH_P=0
CHOICE_PATH_F=0
PATHS=()

set_choice_path(){
	local V="$1"
	while [ "$V" ]; do
		case "${V:0:1}" in
			p) CHOICE_PATH_P=0;;
			P) CHOICE_PATH_P=1;;
			f) CHOICE_PATH_F=0;;
			F) CHOICE_PATH_F=1;;
		esac
		V="${V:1}"
	done
}
show_help(){
	echo "$0 [-i [inf_file]] [-m [path]] [-t <[p|P][f|F]>] [chk_path] [chk_path]"
	echo "  -i [inf_file]     CSV file to save informations of the collect"
	echo "  -m [path]         Move duplicados para path"
	echo "  -t<[p|P][f|F]>   Dá preferência para mover arquivos que contenham (Ex: -tp | -tPF):"
	echo "      p             menor path [default]"
	echo "      P             maior path"
	echo "      f             menor nome de arquivo [default]"
	echo "      F             maior nome de arquivo"
	echo "  [chk_path]        Verifica path e sub-paths se é duplicado"

	exit
}
start_opt(){
	while [[ $# != 0 ]]; do
		KEY="$1"; shift
		case "$KEY" in
			-i)                INFO_FILE="$1";shift;;
			-m)                MOVE_PATH="$1";shift;;
			-t*)               set_choice_path "${1:2}";;
			
			--help)            show_help;;
			*)                 PATHS[${#PATHS[@]}]="$1";;
		esac
	done
	[[ ${#PATHS[@]} == 0 ]] && PATHS[0]="$THIS_PATH"
}

start_opt "$@"
echo ${#PATHS[@]}