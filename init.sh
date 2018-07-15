#!/bin/bash

set -e

/opt/apache-artemis-${ACTIVEMQ_ARTEMIS_VERSION}/bin/artemis create artemis \
    --home /opt/apache-artemis \
    --user artemis \
    --password simetraehcapa \
    --role amq \
    --require-login \
    --cluster-user artemisCluster \
    --cluster-password simetraehcaparetsulc \
    ${ARTEMIS_INSTANCE_DIR} --force

cd ${ARTEMIS_INSTANCE_DIR}/etc && \
  xmlstarlet ed -L -N amq="http://activemq.org/schema" \
    -u "/amq:broker/amq:web/@bind" \
    -v "http://0.0.0.0:8161" bootstrap.xml

chown -R artemis.artemis ${ARTEMIS_INSTANCE_DIR}

