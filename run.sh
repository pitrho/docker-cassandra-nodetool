#!/bin/bash

set -e

die () {
	echo $1
	exit 1
}

LOG_FILE="/var/log/cassandra_nodetool.log"
CRON_FILE="/etc/cron.d/cassandra-nodetool"
: ${CASSANDRA_HOSTS:=''}
: ${CASSANDRA_JMX_PORT:='7199'}
: ${CASSANDRA_JMX_USERNAME='cassandra'}
: ${CASSANDRA_JMX_PASSWORD='cassandra'}
: ${CASSANDRA_USE_JMX_SSL:=false}
: ${CRON_SCHEDULE:=''}
: ${NODETOOL_COMMAND:=''}
: ${NODETOOL_COMMAND_OPTIONS:=''}


# If we're given a list of rancher services for seeds, then use the ips
# from these services.
if [ -n "${CASSANDRA_RANCHER_SERVICES}" ]; then
  # Loop through all the services and concat the ips
  for rancher_service in ${CASSANDRA_RANCHER_SERVICES//,/ } ; do
    node_ip=$(dig +short $rancher_service)
    service_nodes="${service_nodes},${node_ip}"
  done
  CASSANDRA_HOSTS=${service_nodes/,/}
fi

if [ -z $CASSANDRA_HOSTS ]; then
	die "ERROR You must specify at least one cassandra host"
elif [ -z "$CRON_SCHEDULE" ]; then
	die "ERROR You must specify the CRON_SCHEDULE environment variable"
elif [ -z "$NODETOOL_COMMAND" ]; then
	die "ERROR You must specify the NODETOOL_COMMAND environment variable"
fi


# Here we set the JMX access parameters
jvm_path=`update-java-alternatives -l | awk '{print $3}'`
cp $jvm_path/jre/lib/management/jmxremote.password.template $CASSANDRA_CONFIG/jmxremote.password
chmod 400 /etc/cassandra/jmxremote.password

sed -ri 's|^(# )?monitorRole.*|monitorRole QED|' "$CASSANDRA_CONFIG/jmxremote.password"
sed -ri 's|^(# )?controlRole.*|controlRole R&D|' "$CASSANDRA_CONFIG/jmxremote.password"
echo "${CASSANDRA_JMX_USERNAME} ${CASSANDRA_JMX_PASSWORD}" >> "$CASSANDRA_CONFIG/jmxremote.password"

# Here we enable SSL access for JMX
if [ $CASSANDRA_USE_JMX_SSL = true ]; then
  if [ -n "${CASSANDRA_JMX_PORT}" ]; then
    echo "-Dcom.sun.management.jmxremote.port=${CASSANDRA_JMX_PORT}" >> /root/.cassandra/nodetool-ssl.properties
    echo "-Dcom.sun.management.jmxremote.rmi.port=${CASSANDRA_JMX_PORT}"  >> /root/.cassandra/nodetool-ssl.properties
  fi

  echo "-Djavax.net.ssl.keyStore=${CASSANDRA_KEYSTORE_PATH}" >> /root/.cassandra/nodetool-ssl.properties
  echo "-Djavax.net.ssl.keyStorePassword=${CASSANDRA_KEYSTORE_PASSWORD}" >> /root/.cassandra/nodetool-ssl.properties
  echo "-Djavax.net.ssl.trustStore=${CASSANDRA_TRUSTSTORE_PATH}" >> /root/.cassandra/nodetool-ssl.properties
  echo "-Djavax.net.ssl.trustStorePassword=${CASSANDRA_TRUSTSTORE_PASSWORD}" >> /root/.cassandra/nodetool-ssl.properties
  echo "-Dcom.sun.management.jmxremote.ssl.need.client.auth=true" >> /root/.cassandra/nodetool-ssl.properties
  echo "-Dcom.sun.management.jmxremote.registry.ssl=true" >> /root/.cassandra/nodetool-ssl.properties
fi

# Set the cron job
echo "CASSANDRA_CONFIG=${CASSANDRA_CONFIG}" > $CRON_FILE
[ -n "${CASSANDRA_HOSTS}" ] && { echo "CASSANDRA_HOSTS=${CASSANDRA_HOSTS}" >> $CRON_FILE; }
[ -n "${CASSANDRA_JMX_PORT}" ] && { echo "CASSANDRA_JMX_PORT=${CASSANDRA_JMX_PORT}" >> $CRON_FILE; }
[ -n "${CASSANDRA_JMX_USERNAME}" ] && { echo "CASSANDRA_JMX_USERNAME=${CASSANDRA_JMX_USERNAME}" >> $CRON_FILE; }
echo "CASSANDRA_USE_JMX_SSL=${CASSANDRA_USE_JMX_SSL}" >> $CRON_FILE
echo "NODETOOL_COMMAND='${NODETOOL_COMMAND}'" >> $CRON_FILE
echo "NODETOOL_COMMAND_OPTIONS='${NODETOOL_COMMAND_OPTIONS}'" >> $CRON_FILE
echo "LOG_FILE=${LOG_FILE}" >> $CRON_FILE
echo "${CRON_SCHEDULE} root /etc/service/nodetool/run-nodetool.sh >> ${LOG_FILE} 2>&1" >> $CRON_FILE


# Create the log output file (PIPE) if it does not exist
if [ ! -p $LOG_FILE ]; then
  mkfifo $LOG_FILE
fi

tail -f $LOG_FILE
