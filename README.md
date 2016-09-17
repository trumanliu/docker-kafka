Running
=======

### Provisioning

```bash

knife ec2 server create -N 'usw2a-kafka4-prod' -r 'role[base], recipe[apt], recipe[raid]' -E 'prod' -x 'ubuntu' -f m1.xlarge -I 'ami-8eea71be' -Z 'us-west-2a' --region 'us-west-2' -g 'sg-57f21538' -s 'subnet-eb6b619f' -S 'us-west-2-chef2' --ephemeral '/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde' -i ~/.chef/us-west-2-chef2.pem --no-host-key-verify

knife ec2 server create -N 'usw2b-kafka4-prod' -r 'role[base], recipe[apt], recipe[raid]' -E 'prod' -x 'ubuntu' -f m1.xlarge -I 'ami-8eea71be' -Z 'us-west-2b' --region 'us-west-2' -g 'sg-57f21538' -s 'subnet-1a38b172' -S 'us-west-2-chef2' --ephemeral '/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde' -i ~/.chef/us-west-2-chef2.pem --no-host-key-verify

knife ec2 server create -N 'usw2c-kafka4-prod' -r 'role[base], recipe[apt], recipe[raid]' -E 'prod' -x 'ubuntu' -f m1.xlarge -I 'ami-8eea71be' -Z 'us-west-2c' --region 'us-west-2' -g 'sg-57f21538' -s 'subnet-fa7f4abc' -S 'us-west-2-chef2' --ephemeral '/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde' -i ~/.chef/us-west-2-chef2.pem --no-host-key-verify
```

### Build

```bash
docker build -t "kafka":0.8.1.1 .
```

```bash
docker run -d -t -e EXPOSED_PORT=9092 -e  -p 9092:9092 relateiq/kafka
docker run -d -v /mnt/apps/kafka8/data:/data -v /mnt/apps/kafka8/logs:/logs --name kafka8 -P -e BROKER_ID=1 -e CHROOT=/v0_8_1_1 -h localhost --link zookeeper:zookeeper relateiq/kafka:0.8.1.1
```

```bash
knife bootstrap 10.30.10.148 -x ubuntu -N 'usw2b-kafka2-prod' -r 'recipe[apt],recipe[raid],role[base]' -E 'prod' -i ~/.ssh/usw2-docker.pem --sudo
knife bootstrap 10.30.30.22  -x ubuntu -N 'usw2c-kafka1-prod' -r 'recipe[apt],recipe[raid],role[base]' -E 'prod' -i ~/.ssh/usw2-docker.pem --sudo

docker run -rm -t -i -link kafka:kafka7 -link kafka8:kafka8 -link zookeeper:zookeeper kafka-migration bash

sudo docker run -d -v /mnt/apps/kafka8/data:/data -v /mnt/apps/kafka8/logs:/logs --name kafka8 -p 9093:9093 -e EXPOSED_PORT=9093 -e BROKER_ID=0 -e CHROOT=/v0_8_1_1 --link zookeeper:zookeeper relateiq/kafka:0.8.1.1
```

### Local
```bash
sudo docker run -d -v ./data:/data -v ./logs:/logs -h localhost --name kafka8 -p 9093:9093 -p 7203:7203 -e EXPOSED_HOSTNAME=localhost -e EXPOSED_PORT=9092 -e BROKER_ID=1 -e CHROOT=/v0_8_1_1 -e ZOOKEEPER_PORT_2181_TCP_ADDR=127.0.0.1 kafka:0.8.1.1
```

### Staging

```bash
sudo docker run -d -v /mnt/apps/kafka/data:/data -v /mnt/apps/kafka/logs:/logs -h $(hostname) --name kafka8 -p 9092:9092 -p 7203:7203 -e EXPOSED_HOSTNAME=usw2b-kafka2-staging.amz.relateiq.com -e EXPOSED_PORT=9092 -e BROKER_ID=1 -e CHROOT=/v0_8_1_1 -e ZOOKEEPER_PORT_2181_TCP_ADDR=10.30.10.192 kafka:0.8.1
```

### Prod
*BELOW IS PROBABLY OUTDATED* 

```bash
sudo docker run -d -v /mnt/apps/kafka/data:/data -v /mnt/apps/kafka/logs:/logs -h $(hostname) --name kafka8 -p 9092:9092 -p 7203:7203 -e EXPOSED_HOSTNAME=usw2c-kafka4-prod.amz.relateiq.com -e EXPOSED_PORT=9092 -e BROKER_ID=1 -e CHROOT=/v0_8_1_1 -e ZOOKEEPER_PORT_2181_TCP_ADDR=10.30.10.24 kafka:0.8.1.1

sudo docker run -d -v /mnt/apps/kafka/data:/data -v /mnt/apps/kafka/logs:/logs -h $(hostname) --name kafka8 -p 9092:9092 -p 7203:7203 -e EXPOSED_HOSTNAME=usw2b-kafka4-prod.amz.relateiq.com -e EXPOSED_PORT=9092 -e BROKER_ID=2 -e CHROOT=/v0_8_1_1 -e ZOOKEEPER_PORT_2181_TCP_ADDR=10.30.10.24 kafka:0.8.1.1

sudo docker run -d -v /mnt/apps/kafka/data:/data -v /mnt/apps/kafka/logs:/logs -h $(hostname) --name kafka8 -p 9092:9092 -p 7203:7203 -e EXPOSED_HOSTNAME=usw2a-kafka4-prod.amz.relateiq.com -e EXPOSED_PORT=9092 -e BROKER_ID=3 -e CHROOT=/v0_8_1_1 -e ZOOKEEPER_PORT_2181_TCP_ADDR=10.30.10.24 kafka:0.8.1.1
```
### frankfurt
#### 0.8.1.1
```bash
docker run -d -v /mnt/apps/kafka/data:/data -v /mnt/apps/kafka/logs:/logs -h $(hostname) --name kafka -p 9092:9092 -p 7203:7203 -e EXPOSED_HOSTNAME=$(hostname) -e EXPOSED_PORT=9092 -e BROKER_ID=1 -e CHROOT=/Kafka_2015_06 -e ZOOKEEPER_IP=euc1a-zookeeper2-frankfurt.salesforceiq.com:2181,euc1a-zookeeper1-frankfurt.salesforceiq.com:2181,euc1b-zookeeper1-frankfurt.salesforceiq.com -e EXPOSED_PORT=9092 -e BRANCH=master  docker.amz.relateiq.com/relateiq/kafka:latest

docker run -d -v /mnt/apps/kafka/data:/data -v /mnt/apps/kafka/logs:/logs -h $(hostname) --name kafka -p 9092:9092 -p 7203:7203 -e EXPOSED_HOSTNAME=$(hostname) -e EXPOSED_PORT=9092 -e BROKER_ID=2 -e CHROOT=/Kafka_2015_06 -e ZOOKEEPER_IP=euc1a-zookeeper2-frankfurt.salesforceiq.com:2181,euc1a-zookeeper1-frankfurt.salesforceiq.com:2181,euc1b-zookeeper1-frankfurt.salesforceiq.com -e EXPOSED_PORT=9092 -e BRANCH=master  docker.amz.relateiq.com/relateiq/kafka:latest
docker run -d -v /mnt/apps/kafka/data:/data -v /mnt/apps/kafka/logs:/logs -h $(hostname) --name kafka -p 9092:9092 -p 7203:7203 -e EXPOSED_HOSTNAME=$(hostname) -e EXPOSED_PORT=9092 -e BROKER_ID=3 -e CHROOT=/Kafka_2015_06 -e ZOOKEEPER_IP=euc1a-zookeeper2-frankfurt.salesforceiq.com:2181,euc1a-zookeeper1-frankfurt.salesforceiq.com:2181,euc1b-zookeeper1-frankfurt.salesforceiq.com -e EXPOSED_PORT=9092 -e BRANCH=master  docker.amz.relateiq.com/relateiq/kafka:latest

```
