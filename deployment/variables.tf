variable "project" {}

variable "credentials_file" {}

variable "region" {
  default = "europe-central2"
}

variable "zone" {
  default = "europe-central2-a"
}

variable "ubuntu_20_image" {
  default = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20211212"
}

# ------ZooKeeper
variable "zookeeper1_ip" {
  default = "10.1.0.11"
}
variable "zookeeper2_ip" {
  default = "10.1.0.12"
}
variable "zookeeper3_ip" {
  default = "10.1.0.13"
}
variable "zookeeper1_zone" {
  default = "europe-central2-a"
}
variable "zookeeper2_zone" {
  default = "europe-central2-b"
}
variable "zookeeper3_zone" {
  default = "europe-central2-c"
}
variable "zookeeper_machine_type" {
  default = "e2-medium"
}
variable "zookeeper_disk_size" {
  default     = 32
  description = "size in GB"
}
variable "zookeeper_disk_type" {
  default = "pd-ssd"
}

# -------Kafka Broker
variable "kafka1_ip" {
  default = "10.1.0.21"
}
variable "kafka1_zone" {
  default = "europe-central2-a"
}
variable "kafka2_ip" {
  default = "10.1.0.22"
}
variable "kafka2_zone" {
  default = "europe-central2-b"
}
variable "kafka3_ip" {
  default = "10.1.0.23"
}
variable "kafka3_zone" {
  default = "europe-central2-c"
}

variable "kafka_machine_type" {
  default = "n2-highmem-2"
}
variable "kafka_disk_size" {
  default     = 50
  description = "size in GB"
}
variable "kafka_disk_type" {
  default = "pd-balanced"
}
