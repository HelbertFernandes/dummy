#!/bin/bash
if [ ! $1 ]; then
	echo "Sintaxe $0 <eReg>"
	echo "Ex: $0 s/oi/ola/ig"
	echo
	exit
fi
DIR="`pwd`"
if [ ! $DIR ]; then
	DIR="."
fi

for i in `find $DIR`; do
	if [ -f "$i" ]; then
		echo "Updating $i"
		sed -i.bak "$1" "$i"
	fi
done
