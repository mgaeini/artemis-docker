#!/bin/sh
set -e

. /checkDirs.sh

sed -i "s/logger.handlers=.*/logger.handlers=CONSOLE/g" ../etc/logging.properties

# Update users and roles with if username and password is passed as argument
if [[ "$ARTEMIS_USERNAME" && "$ARTEMIS_PASSWORD" ]]; then
  sed -i "s/amq[ ]*=.*/amq=$ARTEMIS_USERNAME\n/g" ../etc/artemis-roles.properties
  sed -i "s/artemis[ ]*=.*/$ARTEMIS_USERNAME=$ARTEMIS_PASSWORD\n/g" ../etc/artemis-users.properties
fi

# Update min memory if the argument is passed
if [[ "$ARTEMIS_MIN_MEMORY" ]]; then
  sed -i "s/-Xms512M/-Xms$ARTEMIS_MIN_MEMORY/g" ../etc/artemis.profile
fi

# Update max memory if the argument is passed
if [[ "$ARTEMIS_MAX_MEMORY" ]]; then
  sed -i "s/-Xmx1024M/-Xmx$ARTEMIS_MAX_MEMORY/g" ../etc/artemis.profile
fi

if [ -f /var/lib/artemis/etc-override/custom-transformations.xslt ]; then
  echo Applying custom-transformations.xslt
  cp /var/lib/artemis/etc/broker.xml /tmp/broker.xml
  xmlstarlet tr /var/lib/artemis/etc-override/custom-transformations.xslt /tmp/broker.xml > /var/lib/artemis/etc/broker.xml
else
  echo No custom-transformations.xslt found
fi

if [ -f /var/lib/artemis/etc-override/broker.xml ]; then
  cp /var/lib/artemis/etc/broker.xml /tmp/broker.xml
  xmlstarlet tr /opt/merge/merge.xslt -s with=/var/lib/artemis/etc-override/broker.xml /tmp/broker.xml > /var/lib/artemis/etc/broker.xml
else
  echo No broker.xml override found
fi

if [ "$1" = 'artemis-server' ]; then
   set -- su-exec artemis "${ARTEMIS_INSTANCE_DIR}/bin/artemis" "run"
fi

exec "$@"
