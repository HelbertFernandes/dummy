#/bin/bash

[ ! "$2" ] && (echo "$0 <port> <ip1> [ip2] .."; exit)

P="$1"; shift
IPS="$@"

for ip in $IPS; do 
	T0=$(date +%s.%N)
	STR="${ip}:              "
	echo -n "${STR:0:17}"
	
	STR="$(nmap -p $P $ip| grep $P)                 "
	echo -n "${STR:0:25}"
	
	TF=$(date +%s.%N)
	echo "$TF - $T0" | bc
done
