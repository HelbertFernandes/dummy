#!/bin/bash
#dir2utf.sh

convert_item(){
	local ITEM="$1"
	local i
	#[ "${ITEM:0:1}" != "/" ] && ITEM="$THIS_PATH/$ITEM"
	if [ -d "$ITEM" ]; then
		IFS=$'\n' && for i in `ls -1 "$ITEM/"`; do
			convert_item "$ITEM/$i"
		done
	elif [ "`get_type_text "$ITEM"`" ]; then
		clear_line
		echo -n "Item: $ITEM"
		#sed -ri 's/\r$//' "$ITEM"
		echo -n ' [LF]'
		local ENCODING=`get_encoding "$ITEM"`
		if [ "$ENCODING" != 'utf-8' ] && [ "$ENCODING" != 'us-ascii' ]; then
			#iconv -f "$ENCODING" -t utf-8 "$ITEM" -o "$ITEM"
			echo -n ' [UTF-8]'
		fi
		echo
		return 0
	fi
	ITEM="Checking: $ITEM"
	clear_line "$ITEM"
	echo -n "$ITEM"
}
get_type_text() {
	file --mime-type -b "$1" | grep 'text'
}
get_encoding(){
	file --mime-encoding -b "$1"
}
clear_line(){
	echo -en '\r'`echo -n "$OLD_TXT" | sed -r 's/./ /g'`'\r'
	OLD_TXT="$1"
}

THIS_PATH=`dirname $0`
OLD_TXT=''
while [ "$1" ];do
	convert_item "$1"
	shift
done
