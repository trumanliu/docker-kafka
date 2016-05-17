FROM java:openjdk-8-jre-alpine

ARG SCALA_VERSION=2.11
ARG KAFKA_VERSION=0.9.0.1
ARG MIRROR=http://apache.mirrors.pair.com

ENV KAFKA_HOME /opt/kafka
ENV PATH $PATH:$KAFKA_HOME/bin

RUN mkdir /opt

# Dependencies
RUN apk add --no-cache supervisor bash

# Kafka
RUN wget -q -O - $MIRROR/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz | \
    tar -xzf - -C /opt && \
    mv /opt/kafka_$SCALA_VERSION-$KAFKA_VERSION /opt/kafka

ADD scripts/start-kafka.sh /usr/bin/

# Supervisor config
ADD supervisor.ini /etc/supervisor.d/supervisor.ini

EXPOSE 9092

VOLUME /opt/kafka/config

CMD ["supervisord", "-n", "-c", "/etc/supervisor.d/supervisor.ini"]
