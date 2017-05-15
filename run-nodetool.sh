#!/bin/bash

set -e

FILE_LOCK='/tmp/repair.lock'

logit () {
	log_date=`date +"%F %T"`
	echo "[$log_date] $1" >> $LOG_FILE
}

die () {
	logit $1
	exit 1
}

lockit () {
	exec 200>$FILE_LOCK
	flock -n 200 && return 0 || return 1
}

run_nodetool () {
	logit "INFO Running nodetool $NODETOOL_COMMAND for node '$1'"
	sleep 1

	ssl=$([ $CASSANDRA_USE_JMX_SSL = true ] && echo "--ssl" || echo '')
	cmd="/usr/bin/unbuffer /usr/bin/nodetool $ssl -h $1 -p $CASSANDRA_JMX_PORT -u $CASSANDRA_JMX_USERNAME -pwf ${CASSANDRA_CONFIG}/jmxremote.password $NODETOOL_COMMAND $NODETOOL_COMMAND_OPTIONS"
	eval $cmd

	if [ $? != 0 ]; then
		die "ERROR nodetool $NODETOOL_COMMAND failed against node $1. Terminating ..."
		exit 1
	fi
}

lockit || die "ERROR could not obtain lock on $FILE_LOCK"

IFS=","
for ip in $CASSANDRA_HOSTS; do
	run_nodetool $ip
done

logit "INFO Successfully executed nodetool $NODETOOL_COMMAND against nodes $CASSANDRA_HOSTS"
