#!/bin/bash
ZONE1="europe-west3-a"
ZONE2="europe-west3-b"
ZONE3="europe-west3-c"

client3_ip=$(gcloud compute instances describe client3 --zone=$ZONE3 \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

rsync -av -e "ssh -i deployment/id_rsa" --exclude="*node_modules*" /home/i557164/Projects/kafka-benchmarking ziyang@"$client3_ip":/home/ziyang/
