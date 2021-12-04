# Kafka-benchmarking

## Benchmark Design

> In essence, **benchmark design leads to a comprehensive specification** whereas benchmark implementation [...] leads to an executable program.
>
> -- Bermbach et. al

## Design (or implementation?) decisions

### Deploy Kafka on GCP

![Deploy Kafka on GCP](diagrams/deploy-kafka-on-gcp.drawio.svg)

#### Context

- We want to benchmark the consistency behavior of Kafka in the cloud (GCP).
- We need a realistic production-ready setup for the results to be meaningful.
- We have limited resources to deploy the system:
  - one person beginner knowledge in Kafka and GCP
  - 50 GCP credits
  - <= 30 hours working time

#### Decisions

- **1 Kafka cluster per region**

  It is recommended to not distribute one cluster across multiple regions, otherwise the latency may be too high.

- **Use a single region on GCP**

  We decide to start with a single region with a single cluster. Using multiple regions may provide a lower latency for users near the region, but it is also more costly. We may also don't have the time to set up mirroring services across different regions.

- **3 Kafka brokers per cluster, deployed in different zones**

  It is common to have `replication-factor` set to `2` or `3` in Kafka considering availability and latency. We chose `3` as it is the default value. \
  We deploy brokers on separate machines in different availability zones to achieve maximal fault tolerance.

- **3 ZooKeeper servers per ensemble, deployed in different zones**

  [ZooKeeper Administrator's Guide](https://zookeeper.apache.org/doc/r3.1.2/zookeeperAdmin.html#sc_designing) recommends to use 3 servers deployed on different hosts as the minimal setup for fault tolerance.

### SUT setup

Common:

- **OS**: Ubuntu server 20.04 LTS

- **Java**: Oracle JDK 11

  - **Reason**: the latest version supported by Kafka 2.8.1

- **Kafka**: 2.8.1

  - **Reason**: the latest 2.x.x version, as version 3 is new and not recommended for production yet.

- **ZooKeeper**: 3.7.0

#### How do we deploy Kafka in multiple regions?

> Kafka was designed to run within a single data center. As such, we discourage distributing brokers in a single cluster across multiple regions. However, we recommend “stretching” brokers in a single cluster across [availability zones](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) within the same region.
>
> -- [confluent](https://www.confluent.io/blog/design-and-deployment-considerations-for-deploying-apache-kafka-on-aws/)

There are several options:

1. **One stretched cluster**
   Run a single Kafka cluster across multiple regions.![kdg2 0107](https://learning.oreilly.com/api/v2/epubs/urn:orm:book:9781492043072/files/assets/kdg2_0107.png)

   (kafka the definitive guide v2)

   - Pro: higher consistency than multiple clusters

   - Con: maybe higher latency than multiple clusters (unless partitions are replicated and distributed properly)

2. **Multiple clusters**
   ![kdg2 0108](https://learning.oreilly.com/api/v2/epubs/urn:orm:book:9781492043072/files/assets/kdg2_0108.png)
   (kafka the definitive guide v2)

   Reference:

   - [Increase Apache Kafka’s resiliency with a multi-Region deployment and MirrorMaker 2 | AWS Big Data Blog](https://aws.amazon.com/blogs/big-data/increase-apache-kafkas-resiliency-with-a-multi-region-deployment-and-mirrormaker-2/)

   - [Multi-Cluster Deployment Options for Apache Kafka: Pros and Cons | Altoros](https://www.altoros.com/blog/multi-cluster-deployment-options-for-apache-kafka-pros-and-cons/)

   - Con:

     - may require MIrrorMaker to synchronize data between clusters
