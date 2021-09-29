#!/bin/bash

if [ ! $2 ]; then
	echo "Compara diretorios"
	echo "Sintaxe: $0 <diretorio_from> <diretorio_to>"
	exit
fi

compara(){
	local DIR1=`ls $1 -1`
	local DIR2=`ls $2 -1`
	for FILE in $DIR1; do
		FILE1="$1/$FILE"
		FILE2="$2/$FILE"
		if [ -f $FILE1 ]; then
			if [ -f $FILE2 ]; then
				C=`cmp $FILE1 $FILE2`
				if [ "$C" ]; then
					echo $C
				fi
			else
				echo "$FILE2 doesn't exist";
			fi
		elif [ -d "$1/$FILE" ]; then
			if [ -d $FILE2 ]; then
				compara $FILE1 $FILE2
			else
				echo "$FILE2 doesn't exist"
			fi
		else
			if [ ! -e $FILE2 ]; then
				echo "$FILE2 doesn't exist"
			fi
		fi
	done
}

compara $1 $2
