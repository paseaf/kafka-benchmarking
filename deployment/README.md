# Deployment

Kafka version: 2.8.1
ZooKeeper version: 3.5.9
https://kafka.apache.org/28/documentation.html#zk
![Deploy Kafka on GCP](/diagrams/deploy-kafka-on-gcp.drawio.svg)

## Set up terraform

Prerequisite:

- install gcloud CLI
- install terraform CLI
- create and download a GCP key file following [this guide](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build?in=terraform/gcp-get-started)
- move the key file to `~/.keys/gcp-key.json`
- Update `terraform.tfvars` file with the following content
  ```bash
  project                  = "<GCP_PROJECT_ID>"
  credentials_file         = "<PATH_TO_GCP_KEY_FILE>"
  ```
- install Ansible with `apt` following [this guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems)
- install python 3.9+
  ```bash
  sudo apt install python3.9
  sudo apt install python-is-python3
  sudo apt install python3-pip
  ```
- install and configure ansible GCP support following [here](https://docs.ansible.com/ansible/latest/scenario_guides/guide_gce.html)

## Set up a ZooKeeper Ensemble of 3 Servers

> Adapted from https://zookeeper.apache.org/doc/r3.5.9/zookeeperAdmin.html#sc_zkMulitServerSetup

Create three VMs on GCP.

For each VM:

0. Update os packages
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
1. Install JDK 11.
   ```bash
   sudo apt install openjdk-11-jdk-headless -y
   ```
2. Install the ZooKeeper Server Package 3.5.9 from [release page](https://zookeeper.apache.org/releases.html).

   ```bash
   wget https://dlcdn.apache.org/zookeeper/zookeeper-3.5.9/apache-zookeeper-3.5.9-bin.tar.gz
   tar -xvf apache-zookeeper-3.5.9-bin.tar.gz
   sudo mv apache-zookeeper-3.5.9-bin /usr/local/zookeeper
   ```

3. Set the Java maximum heap size to 3GB (for 4GB machine)
   ```bash
   cat > /usr/local/zookeeper/conf/zookeeper-env.sh <<'EOF'
   export ZK_SERVER_HEAP=3072
   export SERVER_JVMFLAGS="-Xms${ZK_SERVER_HEAP}m $SERVER_JVMFLAGS"
   EOF
   ```
4. Create configuration file

   ```bash
   # create a conf file
   cat > /usr/local/zookeeper/conf/zoo.cfg <<'EOF'
   tickTime=2000
   dataDir=/var/lib/zookeeper/
   clientPort=2181
   initLimit=5
   syncLimit=2
   server.1=10.1.0.20:2888:3888
   server.2=10.1.0.21:2888:3888
   server.3=10.1.0.22:2888:3888
   EOF
   ```

   Note:

   - `clientPort`: port for clients(Kafka) to connect to.
   - `server.id=hostname:leaderConnectPort:leaderElectionPort`

5. Set up myid file

   ```bash
   sudo mkdir -p /var/lib/zookeeper
   sudo chown -R $USER:$USER /var/lib/zookeeper
   # use 2, 3 for server 2 and 3, respectively.
   cat  > /var/lib/zookeeper/myid<<'EOF'
   1
   EOF
   ```

6. Start ZooKeeper server

   ```bash
   /usr/local/zookeeper/bin/zkServer.sh start
   ```

7. Make ZooKeeper server run on startup:
   1. Open crontab
      ```bash
      crontab -e
      ```
   2. Add task script
      ```bash
      @reboot /usr/local/zookeeper/bin/zkServer.sh start
      ```

Tools:

- Check heap size: start ZooKeeper in foreground and read from log
  ```bash
  /usr/local/zookeeper/bin/zkServer.sh start-foreground
  ```
- Check if ZooKeeper is running
  ```bash
  /usr/local/zookeeper/bin/zkServer.sh status
  ```

## Set up a Kafka Cluster of 3 Servers

For each VM:

0. Update os packages
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
1. Install JDK 11.
   ```bash
   sudo apt install openjdk-11-jdk-headless -y
   ```
2. Install Kafka 2.8.1

   ```bash
   wget https://archive.apache.org/dist/kafka/2.8.1/kafka_2.13-2.8.1.tgz
   tar -zxf kafka_2.13-2.8.1.tgz
   sudo mv kafka_2.13-2.8.1 /usr/local/kafka
   sudo chown -R $USER:$USER /usr/local/kafka
   mkdir /tmp/kafka-logs
   ```

3. Replace server config `/usr/local/kafka/config/server.properties` with `./kafka_server<id>.profiles` in the current path.

   ```bash
   vim /usr/local/kafka/config/server.properties
   # :1,$d
   ```

4. Start Kafka server

   ```bash
   export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
   # run in background
   /usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties
   # or run in foreground for debugging
   /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties

   ```

   1. Test Kafka server

   ```bash
   /usr/local/kafka/bin/kafka-topics.sh --bootstrap-server 10.1.0.23:9092 --create --replication-factor 3 --partitions 1 --topic test
   /usr/local/kafka/bin/kafka-topics.sh --bootstrap-server 10.1.0.23:9092 --describe --topic test

   # produce messages to test topic
   /usr/local/kafka/bin/kafka-console-producer.sh --bootstrap-server 10.1.0.23:9092, --topic test

   # consume messages to test topic
   /usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server 10.1.0.23:9092 --topic test --from-beginning --partition 0
   ```

   Note: in `--bootstrap-server <brokerIp>:<port>`, `<brokerIp>` can be any broker's IP in the cluster 6. Run Kafka on startup:

   ```bash
   crontab -e
   # then add the following line
   /usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties
   @reboot
   ```

   Current problem: a leader is not selected after restart. Have to manually stop and start all brokers.

   ```bash
   /usr/local/kafka/bin/kafka-server-stop.sh -daemon /usr/local/kafka/config/server.properties
   /usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties
   ```
