# Deployment

Kafka version: 2.8.1
ZooKeeper version: 3.5.9
https://kafka.apache.org/28/documentation.html#zk

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
   server.1=10.1.0.5:2888:3888
   server.2=10.1.0.6:2888:3888
   server.3=10.1.0.7:2888:3888
   EOF
   ```

   Note:

   - `clientPort`: port for clients(Kafka) to connect to.
   - `server.id=hostname:leaderConnectPort:leaderElectionPort`

5. Set up myid file

   ```bash
   sudo mkdir -p /var/lib/zookeeper
   sudo chown $USER /var/lib/zookeeper
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
  jps -l
  ```
