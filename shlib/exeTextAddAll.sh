#!/bin/bash

. `dirname $0`/common.sh

[ ! "$1" ] && exit
[ ! -f "$FILE_EXE" ] && touch $FILE_EXE
for i in `ls -1 ${BASE_EXE}*.txt`; do
	if [ "$i" != "$FILE_EXE" ]; then
		echo "Add EXE: $i"
		echo "$1" >> "$i"
	fi
done
