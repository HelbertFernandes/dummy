#!/bin/bash
. ${0%/*}/config.sh

if [ ! "$1" ]; then 
	exit;
fi

DIR=$1
if [ ! "`echo "$DIR" | egrep "^/"`" ]; then DIR="`pwd`/$DIR"; fi

echo "$DIR"
for i in ${TARGET_CONTROL}*; do
	if [ "$i" != "$FILE_CONTROL" ]; then
		echo "$i"
	fi
done

exit

DIR=`echo "$DIR" |  sed -r "s/(\.\.\/)|\.\//\\1/g" | sed -r "s/\/{2,}/\//g"`
while true; do
	TMP=`echo "$DIR" |  sed -r "s/\/\w+\/\.\.//g"`
	if [ "${#TMP}" -eq "${#DIR}" ]; then
		break 
	fi
	DIR="$TMP"
done

FILE=${DIR##*/}
DIR=${DIR%/*}

echo "$DIR - $FILE"

if [ "$DIR" ] && [ -d "$DIR" ]; then
echo ${SOURCE[*]}
	for ELEMENT in ${!SOURCE[@]}; do
		D1="${SOURCE[$ELEMENT]}"
		D2="$TARGET${D1##*/}"
		echo "$D1 - $D2"
	done
fi
