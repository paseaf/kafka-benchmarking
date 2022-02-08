# Deployment

Kafka version: 2.8.1
ZooKeeper version: 3.5.9
https://kafka.apache.org/28/documentation.html#zk
![Deploy Kafka on GCP](../diagrams/deploy-kafka-on-gcp.drawio.svg)

## Deploy System under Test (SUT) to GCP

Note: We created a GCP VM with Ubuntu 20 as our deployment machine.

### Prepare Deployment Machine

We use Terraform and Ansible to deploy the cluster. Install them on your deployment machine as follows. (We used Ubuntu 20.04 LTS).

#### Install and Configure Terraform

Terraform is used to provision benchmark machines on GCP.
Install it as follows:

1. Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) and `gcloud init` it with your GCP project

2. Install [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/gcp-get-started)

3. Create and download a GCP _service account key_ (in JSON) following [_Set up GCP_ in this guide](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build?in=terraform/gcp-get-started).\
   Terraform will use it to manage your GCP resources. Move the key file to `~/.gcp-key.json`

4. Update `terraform/terraform.tfvars` file with the following content

   ```bash
   project                  = "<GCP_project_ID>"
   credentials_file         = "<path_to_GCP_key_file>"
   ```

5. Verify if your Terraform is successfully set up.
   ```bash
   cd terraform
   terraform init # initialize the working directory
   terraform plan # preview the changes
   ```
   You should not see any error message in the output.

#### Set up Ansible

Set up [Ansible](https://www.ansible.com/) to configure our benchmark VMs

1. Install Ansible
   ```bash
   sudo apt update
   sudo apt install software-properties-common
   sudo add-apt-repository --yes --update ppa:ansible/ansible
   sudo apt install ansible
   ```
   For other distros follow [this guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems). (We used Ansible verison 2.12.1)

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

- Create an SSH key and add it to your GCP project.

  ```bash
  # create an ssh key
  ssh-keygen -t rsa -b 4096 -C "ansible" -f ~/.ssh/ansible -N ""

  # add the ssh key to GCP project
  public_key=$(cat ~/.ssh/ansible.pub)
  echo "ansible":"$public_key" > ./temp-keyfile
  gcloud compute project-info add-metadata --metadata-from-file=ssh-keys=./temp-keyfile
  rm ./temp-keyfile
  ```

- Open inventory file `ansible/inventory.gcp.yml`, Update `projects` property with your GCP project ID

  ```bash
  # ...
  projects:
    - <your GCP project ID>
  # ...
  ```

- :tada: Congratulations! You can now use Terraform and Ansible to provision and configure the SUT.

### Provision and Configure SUT

1. Create VMs on GCP

   In `/deployment/terraform` directory, run:

   ```bash
   terraform apply
   ```

   You should see the external IP addresses of all VMs in the output after execution.

2. Review the inventory file `/deployment/ansible/inventory.gcp.yml` and adapt `compose` property if applicable.
3. Install and run ZooKeeper, Kafka

   In `/deployment/ansible` directory, run:

   ```bash
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
