#!/bin/bash -x

# Necessary?

EXTENSION=""
case $BRANCH in
  prod)
    EXTENSION=".prod"
    CHROOT=${ZOOKEEPER_CHROOT:-/v0_9_0_1_prod}

    # TODO Service discovery
    ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-2181}
  ;;
  staging)
    EXTENSION=".staging"
    CHROOT=${ZOOKEEPER_CHROOT:-/v0_9_0_1_staging}

    # TODO Service discovery
    ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-2181}
  ;;
  rc)
    EXTENSION=".rc"
    CHROOT=${ZOOKEEPER_CHROOT:-/v0_9_0_1_rc}

    # TODO Service discovery
    ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-2181}
  ;;
  kafka-0.9.0.1)
    EXTENSION=".kafka-0.9.0.1"
    CHROOT=${ZOOKEEPER_CHROOT:-/v0_9_0_1_test}

    # TODO Service Discovery
    ZOOKEEPER_PORT=${ZOOKEEPER_PORT:-2181}
  ;;
  *)
    # Developer environments, etc.
    EXTENSION=".default"
    EXPOSED_HOST="${EXPOSED_HOST:-127.0.0.1}"
    ZOOKEEPER_IP=$ZOOKEEPER_PORT_2181_TCP_ADDR
    ZOOKEEPER_PORT=$ZOOKEEPER_PORT_2181_TCP_PORT

  ;;
esac

IP=$(cat /etc/hosts | head -n1 | awk '{print $1}')
PORT=9092

cat /kafka/config/server.properties${EXTENSION} \
  | sed "s|{{ZOOKEEPER_IP}}|${ZOOKEEPER_IP}|g" \
  | sed "s|{{ZOOKEEPER_PORT}}|${ZOOKEEPER_PORT}|g" \
  | sed "s|{{BROKER_ID}}|${BROKER_ID:-0}|g" \
  | sed "s|{{CHROOT}}|${CHROOT:-}|g" \
  | sed "s|{{EXPOSED_HOST}}|${EXPOSED_HOST:-$IP}|g" \
  | sed "s|{{PORT}}|${PORT:-9092}|g" \
  | sed "s|{{EXPOSED_PORT}}|${EXPOSED_PORT:-9092}|g" \
   > /kafka/config/server.properties

export CLASSPATH=$CLASSPATH:/kafka/lib/slf4j-log4j12.jar
export JMX_PORT=7203

if [ -z $KAFKA_JMX_OPTS ]; then
    KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true"
    KAFKA_JMX_OPTS="$KAFKA_JMX_OPTS -Dcom.sun.management.jmxremote.authenticate=false"
    KAFKA_JMX_OPTS="$KAFKA_JMX_OPTS -Dcom.sun.management.jmxremote.ssl=false"
    KAFKA_JMX_OPTS="$KAFKA_JMX_OPTS -Dcom.sun.management.jmxremote.rmi.port=$JMX_PORT"
    KAFKA_JMX_OPTS="$KAFKA_JMX_OPTS -Dcom.sun.management.jmxremote.port=$JMX_PORT"
    KAFKA_JMX_OPTS="$KAFKA_JMX_OPTS -Djava.rmi.server.hostname=${JAVA_RMI_SERVER_HOSTNAME:-$EXPOSED_HOST}"
    export KAFKA_JMX_OPTS
fi

echo "Starting kafka"
exec /kafka/bin/kafka-server-start.sh /kafka/config/server.properties
