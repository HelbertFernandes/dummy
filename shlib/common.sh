#!/bin/bash

THIS_FILE=`readlink -f $0`
THIS_DIR=`dirname $THIS_FILE`
BASE_DIR=`dirname $THIS_DIR`
BASE_EXE="$BASE_DIR/anyDevice/.exeText_"
FILE_EXE="${BASE_EXE}`hostname`.txt"

CRON_EXE_FILE="$THIS_DIR/exeTextAddAll.sh"
