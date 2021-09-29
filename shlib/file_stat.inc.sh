#!/bin/bash

#Modo de uso
#. /var/www/html/shared/shlib/file_stat.inc.sh
# TEMPO=`file_lastAccessTime "FILE"`
# TEMPO=`file_lastModifyTime "FILE"`
# TEMPO=`file_lastChangeTime "FILE"`

file_lastAccessTime(){
	local LAST_ACCESS=`stat -c %X "$1"`
	local NOW_SECONDS=`date +%s`
	echo $(( NOW_SECONDS - LAST_ACCESS ))
}
file_lastModifyTime(){
	local LAST_ACCESS=`stat -c %Y "$1"`
	local NOW_SECONDS=`date +%s`
	echo $(( NOW_SECONDS - LAST_ACCESS ))
}
file_lastChangeTime(){
	local LAST_ACCESS=`stat -c %Z "$1"`
	local NOW_SECONDS=`date +%s`
	echo $(( NOW_SECONDS - LAST_ACCESS ))
}

file_lastAccessTime "$1"
file_lastModifyTime "$1"
file_lastChangeTime "$1"
