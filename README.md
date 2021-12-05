# Kafka-benchmarking

## Benchmark Design

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

     - may require MirrorMaker to synchronize data between clusters
