#!/bin/bash
#
# Create GCP VM
# Note: Re-running this script will fail. You have to remove the existing VM and the firewall rules.

set -euo pipefail # stop execution when an error occurs

USERNAME=ziyang
ZONE1="europe-west3-a"
ZONE2="europe-west3-b"
ZONE3="europe-west3-c"
REGION="europe-west3"
SUT_TAG="kafka-sut"
TEMP_KEY_FILE="temp_keyfile"
SSH_KEY_FILE="id_rsa"
ZOOKEEPER_MACHINE="e2-medium"
KAFKA_MACHINE="n2-highmem-2"
VPC="kafka-network"
SUT_SUBNET="sut-subnet"



# ---------------- Preparation ------------------

# Check if a local SSH key pair exists
if ! test -f $SSH_KEY_FILE; then
    # 1. Generate a local SSH key pair, if it does not exist
    ssh-keygen -t rsa -f $SSH_KEY_FILE -C "$USERNAME" -b 2048 -P "" > /dev/null
    echo 'Generated SSH key'
fi

# Read the SSH public key
public_key=$(cat id_rsa.pub)
# 1. Format and output it into the TEMP_KEY_FILE
echo "$USERNAME":"$public_key" > $TEMP_KEY_FILE

# 2. Add the SSH public key to our project
gcloud compute project-info add-metadata --metadata-from-file=ssh-keys=$TEMP_KEY_FILE
# Remove the temporary TEMP_KEY_FILE
rm $TEMP_KEY_FILE

# create VPC network for SUT
gcloud compute networks create $VPC --subnet-mode=custom 
gcloud compute networks subnets create $SUT_SUBNET --network=$VPC --range=10.1.0.0/16 --region=$REGION
gcloud compute firewall-rules create allow-icmp-tcp-udp-ssh --action=allow --target-tags=$SUT_TAG --network=$VPC --rules=tcp,icmp,udp 

# ---------------- Create ZooKeeper VMs ------------------

gcloud compute addresses create zookeeper1-ip --region=$REGION
gcloud compute addresses create zookeeper2-ip --region=$REGION
gcloud compute addresses create zookeeper3-ip --region=$REGION

gcloud compute instances create zookeeper-server1 --zone=$ZONE1 \
    --machine-type=$ZOOKEEPER_MACHINE --tags=$SUT_TAG \
    --network-interface network=$VPC,subnet=$SUT_SUBNET,address="zookeeper1-ip" \
    --create-disk=size=64GB,type=pd-ssd,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20211212

gcloud compute instances create zookeeper-server2 --zone=$ZONE2 \
    --machine-type=$ZOOKEEPER_MACHINE --tags=$SUT_TAG \
    --network-interface network=$VPC,subnet=$SUT_SUBNET,address="zookeeper2-ip" \
    --create-disk=size=64GB,type=pd-ssd,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20211212

gcloud compute instances create zookeeper-server3 --zone=$ZONE3 \
    --machine-type=$ZOOKEEPER_MACHINE --tags=$SUT_TAG \
    --network-interface network=$VPC,subnet=$SUT_SUBNET,address="zookeeper3-ip" \
    --create-disk=size=64GB,type=pd-ssd,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20211212

# Follow README.md to install and configure the ZooKeeper ensemble

# ---------------- Create Kafka VMs ------------------
gcloud compute addresses create kafka1-ip --region=$REGION
gcloud compute addresses create kafka2-ip --region=$REGION
gcloud compute addresses create kafka3-ip --region=$REGION


gcloud compute instances create kafka-broker1 --zone=$ZONE1 \
    --machine-type=$KAFKA_MACHINE --tags=$SUT_TAG \
    --network-interface network=$VPC,subnet=$SUT_SUBNET,address="kafka1-ip" \
    --create-disk=size=100GB,type=pd-balanced,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20211212

gcloud compute instances create kafka-broker2 --zone=$ZONE2 \
    --machine-type=$KAFKA_MACHINE --tags=$SUT_TAG \
    --network-interface network=$VPC,subnet=$SUT_SUBNET,address="kafka2-ip" \
    --create-disk=size=100GB,type=pd-balanced,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20211212

gcloud compute instances create kafka-broker3 --zone=$ZONE3 \
    --machine-type=$KAFKA_MACHINE --tags=$SUT_TAG \
    --network-interface network=$VPC,subnet=$SUT_SUBNET,address="kafka3-ip" \
    --create-disk=size=100GB,type=pd-balanced,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20211212

# Follow README.md to install and configure the Kafka cluster
