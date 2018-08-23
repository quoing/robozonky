#!/bin/sh
export JAVA_OPTS="$JAVA_OPTS \
    -Drobozonky.properties.file=$CONFIG_DIRECTORY/robozonky.properties \
    -Dlogback.configurationFile=$CONFIG_DIRECTORY/logback.xml \
    -Dcom.sun.management.jmxremote \
    -Dcom.sun.management.jmxremote.port=7091 \
    -Dcom.sun.management.jmxremote.ssl=false \
    -Dcom.sun.management.jmxremote.authenticate=false \
    -Djmx.remote.x.notification.buffer.size=50"

PARAM_DRY=""
if [ -n "$DRY" ]; then
	echo "Starting robozonky with \"dry\" parameter"
	PARAM_DRY="--dry"
fi
export PARAM_DRY

PARAM_KEYSTORE="/var/robozonky/robozonky.keystore"
if [ -n "$KEYSTORE" ]; then
	echo "Changing default keystore to: $KEYSTORE"
	PARAM_KEYSTORE="$KEYSTORE"
fi

PARAM_KEYSTORE_PASSWORD="$KEYSTORE_PASSWORD"
if [ -z "$KEYSTORE_PASSWORD" ]; then
	echo "No keystore password specified. Exiting."
	exit 1
fi

PARAM_STRATEGY="$STRATEGY"
if [ -z "$STRATEGY" ]; then
	echo "No strategy selected. Exiting."
	exit 1
fi

sh $INSTALL_DIRECTORY/robozonky.sh $PARAM_DRY -g $PARAM_KEYSTORE -p $PARAM_KEYSTORE_PASSWORD -s $PARAM_STRATEGY

