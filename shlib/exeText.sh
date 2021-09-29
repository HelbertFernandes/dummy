#!/bin/bash

. `dirname $0`/common.sh

TIMEINI=`date +%s`
FILETMP="/var/tmp/.exeText_$TIMEINI"
TIMENOW=$TIMEINI

>> "$FILE_EXE"
TIME=0
rm -f "$FILETMP"
while [  $TIME -lt 59 ]; do 
	if [ -s "$FILE_EXE" ]; then
		mv "$FILE_EXE" "$FILETMP"
		>> "$FILE_EXE"
		/bin/bash "$FILETMP"
		rm -f "$FILETMP"
	fi
	sleep 1
	TIMENOW=`date +%s`
	TIME=`echo $(( $TIMENOW - $TIMEINI ))`
done
