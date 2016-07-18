#!/usr/bin/env bash

CONF="$KAFKA_HOME/config/server.properties"

function edit_properties() {
  local FILE="$1"
  local RAW_KEY="$2"
  local RAW_VALUE="$3"

  if [ -z "$FILE" ]; then
      return 2
  fi
  if [ -z "$RAW_KEY" ]; then
      return 1
  fi
  if [ -z "$RAW_VALUE" ]; then
      return 0
  fi

  # sanitize for grep/sed pattern
  local KEY=$(echo "$RAW_KEY" | sed 's/[]\/$*.^|[]/\\&/g')
  local VALUE=$(echo "$RAW_VALUE" | sed 's/[]\/$*.^|[]/\\&/g')

  # replace if found, append if not
  grep "^\\s*\($KEY\)" "$FILE" > /dev/null \
    && sed -i "s/^\\s*\($KEY\)\\s*=\(.*\)$/\1=$VALUE/" "$FILE" \
    || echo "$RAW_KEY=$RAW_VALUE" >> "$FILE"
}

edit_properties "$CONF" 'broker.id' "$KAFKA_BROKER_ID"
edit_properties "$CONF" 'zookeeper.connect' "${ZOOKEEPER_PORT_2181_TCP_ADDR:-zookeeper}:${ZOOKEEPER_PORT_2181_TCP_PORT:-2181}$CHROOT"
edit_properties "$CONF" 'advertised.host.name' "$KAFKA_ADVERTISED_HOST_NAME"
edit_properties "$CONF" 'advertised.port' "$KAFKA_ADVERTISED_PORT"
edit_properties "$CONF" 'port' "$KAFKA_PORT"
edit_properties "$CONF" 'log.dirs' "$KAFKA_LOG_DIRS"
edit_properties "$CONF" 'delete.topic.enable' 'true'
edit_properties "$CONF" 'log.retention.hours' "$KAFKA_LOG_RETENTION_HOURS"
edit_properties "$CONF" 'log.retention.bytes' "$KAFKA_LOG_RETENTION_BYTES"
edit_properties "$CONF" 'log.num.partitions' "$KAFKA_NUM_PARTITIONS"
edit_properties "$CONF" 'auto.create.topics.enable' "$KAFKA_AUTO_CREATE_TOPICS"
edit_properties "$CONF" 'listeners' "$KAFKA_LISTENERS"

# Run Kafka
kafka-server-start.sh "$CONF"
