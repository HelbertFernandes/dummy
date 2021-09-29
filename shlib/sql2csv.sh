#!/bin/bash

[ ! "$1" ] && echo 'Falta tabela' && exit;
[ "$2" ] && TARGET_DIR="$2" || TARGET_DIR=`dirname $0`;

TBL="$1"
TMP_FILE="/tmp/${TBL}.csv"
rm -f "$TMP_FILE"
HEAD=`mysql -e "SELECT GROUP_CONCAT(COLUMN_NAME SEPARATOR ';') FROM information_schema.COLUMNS WHERE CONCAT(TABLE_SCHEMA,'.',TABLE_NAME)='$TBL'" | sed 1d`
#echo -e $HEAD >> "$TMP_FILE"
mysql -e "SELECT * FROM $TBL INTO OUTFILE '$TMP_FILE' FIELDS TERMINATED BY ';' ENCLOSED BY '\"' LINES TERMINATED BY '\\n';"

FILE="$TARGET_DIR/${TBL}.csv"

rm -f "${FILE}.bz2"
mv -f "$TMP_FILE" "$TARGET_DIR"
sed -ri 's/\\N\b//g' "$FILE"
sed -ri "1s/^(.)/${HEAD}\n\1/" "$FILE"
#cat "$FILE"
bzip2 "$FILE"