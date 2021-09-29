#!/bin/bash

if [ ! "$1" ]; then 
	echo "$0 <config.ini>"
	exit
fi
. ${0%/*}/config.sh
cfg.parser "$1"
cfg.section.config
cfg.section.sources

if [ -s $FILE_CONTROL ]; then
	F="$FILE_CONTROL.tmp_`date "+%Y%m%d%H%M%S"`"
	mv -f $FILE_CONTROL $F
	> $FILE_CONTROL
	. $F
	rm -f $F
	> $TARGET/.compact
fi
