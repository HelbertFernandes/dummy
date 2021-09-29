#/bin/bash

[ "$1" ] && P="$1" || P=$(pwd)
for i in $(ls -1 "$P");do 
	du -sh $i
done
