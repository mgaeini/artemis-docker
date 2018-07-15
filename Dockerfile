FROM openjdk:8-jre-alpine
MAINTAINER Mohsen Gaeini <mgaeini@yahoo.com>

# add user and group for artemis
RUN addgroup -S artemis && adduser -S -G artemis artemis

RUN apk add --no-cache libaio xmlstarlet jq su-exec



ENV ACTIVEMQ_ARTEMIS_VERSION 2.6.2
ENV HAWTIO_VERSION 1.5.4
RUN set -x && \
  apk add --no-cache --virtual .deps wget gnupg && \
  mkdir /opt && cd /opt && \
  wget -q https://repository.apache.org/content/repositories/releases/org/apache/activemq/apache-artemis/${ACTIVEMQ_ARTEMIS_VERSION}/apache-artemis-${ACTIVEMQ_ARTEMIS_VERSION}-bin.tar.gz && \
  wget -q https://repository.apache.org/content/repositories/releases/org/apache/activemq/apache-artemis/${ACTIVEMQ_ARTEMIS_VERSION}/apache-artemis-${ACTIVEMQ_ARTEMIS_VERSION}-bin.tar.gz.asc && \
  wget -q http://apache.org/dist/activemq/KEYS && \
  gpg --import KEYS && \
  gpg apache-artemis-${ACTIVEMQ_ARTEMIS_VERSION}-bin.tar.gz.asc && \
  tar xfz apache-artemis-${ACTIVEMQ_ARTEMIS_VERSION}-bin.tar.gz && \
  ln -s apache-artemis-${ACTIVEMQ_ARTEMIS_VERSION} apache-artemis && \
  rm -f apache-artemis-${ACTIVEMQ_ARTEMIS_VERSION}-bin.tar.gz KEYS apache-artemis-${ACTIVEMQ_ARTEMIS_VERSION}-bin.tar.gz.asc && \
  apk del .deps

# Use the local hawtio artemis plugin


# Create broker instance
ENV ARTEMIS_INSTANCE_DIR /var/lib/artemis
COPY init.sh /init.sh
RUN chmod +x /init.sh && . /init.sh

RUN mkdir -p /opt/merge
COPY merge.xslt /opt/merge

# Web Server
EXPOSE 8161

# Port for CORE,MQTT,AMQP,HORNETQ,STOMP,OPENWIRE
EXPOSE 61616

# Port for HORNETQ,STOMP
EXPOSE 5445

# Port for AMQP
EXPOSE 5672

# Port for MQTT
EXPOSE 1883

#Port for STOMP
EXPOSE 61613

# Expose some outstanding folders"]
VOLUME ["/var/lib/artemis/data"]
VOLUME ["/var/lib/artemis/tmp"]
VOLUME ["/var/lib/artemis/etc"]
VOLUME ["/var/lib/artemis/etc-override"]

WORKDIR /var/lib/artemis/bin

COPY docker-entrypoint.sh /
COPY checkDirs.sh /checkDirs.sh
RUN chmod +x /docker-entrypoint.sh && chmod +x /checkDirs.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["artemis-server"]
