#!/bin/bash
if [ ! $1 ]; then
	echo "Sintaxe $0 <extension>"
	exit
fi
DIR="`pwd`"
if [ ! $DIR ]; then
        DIR="."
fi

for i in `find $DIR -name "*.$1"`; do
	if [ -f "$i" ]; then
		echo "Deleting $i"
		rm "$i" -f
	fi
done
