variable "project" {}

variable "credentials_file" {}

variable "region" {
  default = "europe-central2"
}

variable "zone" {
  default = "europe-central2-a"
}

variable "ubuntu-20-image" {
  default = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20211212"
}

# ------ZooKeeper
variable "zookeeper1-ip" {
  default = "10.1.0.11"
}
variable "zookeeper2-ip" {
  default = "10.1.0.12"
}
variable "zookeeper3-ip" {
  default = "10.1.0.13"
}
variable "zookeeper1-zone" {
  default = "europe-central2-a"
}
variable "zookeeper2-zone" {
  default = "europe-central2-b"
}
variable "zookeeper3-zone" {
  default = "europe-central2-c"
}
variable "zookeeper-machine-type" {
  default = "e2-medium"
}
variable "zookeeper-disk-size" {
  default     = 32
  description = "size in GB"
}
variable "zookeeper-disk-type" {
  default = "pd-ssd"
}

# -------Kafka Broker
variable "kafka1-ip" {
  default = "10.1.0.21"
}
variable "kafka1-zone" {
  default = "europe-central2-a"
}
variable "kafka2-ip" {
  default = "10.1.0.22"
}
variable "kafka2-zone" {
  default = "europe-central2-b"
}
variable "kafka3-ip" {
  default = "10.1.0.23"
}
variable "kafka3-zone" {
  default = "europe-central2-c"
}

variable "kafka-machine-type" {
  default = "n2-highmem-2"
}
variable "kafka-disk-size" {
  default     = 50
  description = "size in GB"
}
variable "kafka-disk-type" {
  default = "pd-balanced"
}
