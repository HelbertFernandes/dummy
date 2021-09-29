#!/bin/bash

BASEDIR='/data/shared/bkpConfig'
DIR="$BASEDIR/`hostname`"
FILES=(
	'/var/spool/cron/*'
	'/root/.bashrc'
	'/root/.bash_profile'
	'/etc/hosts'
	'/etc/fstab'
	'/etc/crontab'
	'/etc/resolv.conf'
	'/etc/my.cnf'
	'/etc/php.ini'
	'/etc/yum.conf'
	'/etc/yum.repos.d/*'
	'/etc/ssh/*'
	'/etc/haproxy/haproxy.cfg'
	'/etc/sysconfig/network-scripts/ifcfg-*'
	'/etc/sysconfig/network-scripts/route-*'
	'/etc/httpd/conf/*'
	'/etc/httpd/conf.d/*'
	'/etc/httpd/conf.modules.d/*'
	'/etc/firewalld/firewalld.conf'
	'/etc/firewalld/lockdown-whitelist.xml'
	'/etc/firewalld/zones/*'
)

for i in ${FILES[@]}; do 
	if [ -f $i ]; then
		#echo $i
		TO_DIR="$DIR`dirname $i`"
		mkdir -p $TO_DIR
		cp -v -f -P -p -u $i $TO_DIR
	fi
done
route > "$DIR/route"

cd $BASEDIR
svn update *
svn add --force *
for i in `svn status | grep "^[!C] " | cut -c 8-`; do
	svn revert "$i"
done  
svn commit -m "`basename $0`"