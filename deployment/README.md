# Deployment

Kafka version: 2.8.1
ZooKeeper version: 3.5.9
https://kafka.apache.org/28/documentation.html#zk
![Deploy Kafka on GCP](../diagrams/deploy-kafka-on-gcp.drawio.svg)

## Deploy Kafka Cluster

Follow the steps below to deploy and run Kafka cluster on GCP with our automated scripts.

### Prerequisite

Set up [Terraform](https://www.terraform.io/) to provision benchmark infrastructure on GCP:

- Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) and `gcloud init` it with your GCP project

- Install [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/gcp-get-started)

- Create and download a GCP key file (in JSON) following [this guide](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build?in=terraform/gcp-get-started)

- Move the key file to `~/.gcp-key.json`

- Update `terraform.tfvars` file with the following content
  ```bash
  project                  = "<GCP_PROJECT_ID>"
  credentials_file         = "~/.keys/gcp-key.json"
  ```

Set up [Ansible](https://www.ansible.com/) to configure our benchmark VMs

- Install Ansible with `apt` following [this guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems). (We used Ansible verison 2.12.1)

- Install Python (We used Python 3.9)

  ```bash
  sudo apt install python3.9
  sudo apt install python-is-python3
  sudo apt install python3-pip
  ```

- Install GCP support for Ansible

  ```bash
  pip install requests google-auth
  ansible-galaxy collection install google.cloud
  ```

  This allows us to generate Ansible inventory file dynamically by reading from GCP.

- Create and configure an ssh key for Ansible to connect to GCP.

  ```bash
  # create an ssh key
  ssh-keygen -t rsa -b 4096 -C "ansible" -f ~/.ssh/ansible -N ""
  # add the ssh key to project ssh-keys
  public_key=$(cat ~/.ssh/ansible.pub)
  echo "ansible":"$public_key" > ./temp-keyfile
  gcloud compute project-info add-metadata --metadata-from-file=ssh-keys=./temp-keyfile
  rm ./temp-keyfile
  ```

- Update inventory file `inventory.gcp.yml`, `projects` property with your GCP project ID

  ```bash
  # ...
  projects:
    - <your GCP project ID>
  # ...
  ```

- :tada: Congratulations! You can now use Terraform and Ansible to provision and configure the project.

### Provision and Configure SUT

1. Create VMs on GCP

   In `/deployment/` directory:

   ```bash
   terraform init
   terraform apply # enter yes when prompt
   ```

   You should see the external IP addresses of all VMs in output.

2. Install and run ZooKeeper, Kafka

   ```bash
   cd ansible
   ansible-playbook main.yml
   ```

   Kafka cluster should now be up and running.

## Common ZooKeeper and Kafka Commands

You can `ssh ansible@<ip>` to these VMs and use the following commands when needed.

### ZooKeeper Commands

- Run in background

  ```bash
  /usr/local/zookeeper/bin/zkServer.sh start
  ```

- Run in foreground (for debugging or checking heap size)

  ```bash
  /usr/local/zookeeper/bin/zkServer.sh start-foreground
  ```

- Check running status

  ```bash
  /usr/local/zookeeper/bin/zkServer.sh status
  ```

### Kafka Commands

- Run in background

  ```bash
  /usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties
  ```

- Run in foreground

  ```bash
  /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties
  ```

- Stop

  ```bash
  /usr/local/kafka/bin/kafka-server-stop.sh /usr/local/kafka/config/server.properties
  ```
