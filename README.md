# Docker Cassandra Nodetool

Base docker image to run the Cassandra Nodetool utility. It uses
[phusion's](https://github.com/phusion/baseimage-docker) base docker image.

Aside from the original functionality, this image has the ability to run on
Rancher.

## Building the image

Clone the repository

        git clone https://github.com/pitrho/docker-cassandra-nodetool.git
        cd docker-cassandra-nodetool
        ./build.sh

De default tag for the new image is pitrho/cassadra-nodetool. If you want to
specify a different tag, pass the -t flag along with the tag name:

    ./build.sh -t new/tag

Be default, the image installs version 2.2.3. If you want to install
a different version, pass the -v flag along with the version name:

    ./build.sh -v 3.0.0

## Environment Variables

The following environment variables can be used to adjust which nodetool command
to run and which options to pass.

### CASSANDRA_HOSTS
This variable is for specifying the set of nodes (comma-separated) for which to
run the nodetool command against.

### CASSANDRA_RANCHER_SERVICES
If running on Rancher, you can specify a comma-separated list of services that
correspond to the Cassandra nodes. Then, that list is used to populate the
`CASSANDRA_HOSTS` varaible above.

###CASSANDRA_JMX_PORT
This variable is used for specify the JMX port to connect to Cassandra. It
defaults to `7199`.

###CASSANDRA_JMX_USERNAME
This variable is used to specify the JMX user to connect to Cassandra. It
defaults to `cassandra`.

###CASSANDRA_JMX_PASSWORD
This variable is used to specify the JMX password to connect to Cassandra. It
defaults to `cassandra`.

###CASSANDRA_USE_JMX_SSL
This variable is used to specify that the nodetool must use SSL when connecting
to JMX. It defaults to `false`.

###CASSANDRA_KEYSTORE_PATH
If `CASSANDRA_USE_JMX_SSL` is set to true, then this variable is used to
specify the keystore to use when connecting to JMX.

###CASSANDRA_KEYSTORE_PASSWORD
If `CASSANDRA_USE_JMX_SSL` is set to true, then this variable is used to
specify the keystore password to use when connecting to JMX.

###CASSANDRA_TRUSTSTORE_PATH
If `CASSANDRA_USE_JMX_SSL` is set to true, then this variable is used to
specify the truststore to use when connecting to JMX.

###CASSANDRA_TRUSTSTORE_PASSWORD
If `CASSANDRA_USE_JMX_SSL` is set to true, then this variable is used to
specify the truststore password to use when connecting to JMX.

###CRON_SCHEDULE
This variable is used to specify the cron schedule to run the nodetool command
(i.e 0 6 0 0 0 could be used to run the command everyday at 6 AM)

###NODETOOL_COMMAND
This variable is used to specify the command to run through nodetool
(ie. repair)

###NODETOOL_COMMAND_OPTIONS
This variable is used to specify any options to pass to the command above.


## License
See the license file.

## Contributors

* [Alejadnro Mesa](https://github.com/alejom99)
