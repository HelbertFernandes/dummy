#!/bin/bash
if [ -e "$1/.compact" ]; then
	rm -f $1/.compact
	mkdir -p /mnt/storage/backup/$1
	tar cjf /mnt/storage/backup/$1/development_`date "+%Y%m%d"`.tar.bz2 $1
fi
