#!/bin/bash

. `dirname $0`/common.sh

[ ! "$1" ] && exit
echo "$@" >> "$FILE_EXE"
