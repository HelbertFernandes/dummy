#!/bin/bash

UPTIME=$(awk '{print $1}' /proc/uptime)
#[[ $(echo "$UPTIME < 3000" | bc) = 1 ]] && exit

LOAD=$(awk '{print $3}' /proc/loadavg)
[[ $(echo "$LOAD > 70" | bc) = 1 ]] && reboot
