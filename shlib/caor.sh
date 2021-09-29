#!/bin/bash

if [ ! "$1" ]; then
	echo "Passagem de parametro obrigatória $0 <data_base>"
	exit;
fi
D="$1"
for T in `mysql -e "show tables from $D" | sed 1d`; do 
	echo "${D}.$T ..."
	mysql -e "optimize table ${D}.$T;"
	mysql -e "repair   table ${D}.$T;"
	echo
done
