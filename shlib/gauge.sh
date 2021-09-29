#!/bin/bash
	# dvdcopy.sh - A sample shell script to display a progress bar
# set counter to 0 
counter=0
(
# set infinite while loop
while (( counter <= 100 ));do
	echo XXX
	echo $counter
	echo info $counter
	echo xxxx $counter
	echo XXX
	(( counter++ ))
	sleep .01
done
) | 
dialog --title "File Copy" --gauge '' 7 70 0
read -N 1 aaaaaa



