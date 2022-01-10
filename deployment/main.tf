terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.5.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "benchmark_vpc" {
  name                    = "benchmark-vpc"
  description             = "network for kafka benchmarking"
  auto_create_subnetworks = false
}
resource "google_compute_firewall" "benchmark_vpc_rules" {
  name    = "benchmark-vpc-rules"
  network = google_compute_network.benchmark_vpc.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_subnetwork" "cluster_subnet" {
  name          = "kafka-cluster-subnet"
  ip_cidr_range = "10.1.0.0/16"
  network       = google_compute_network.benchmark_vpc.id
}
resource "google_compute_firewall" "cluster_subnet_rules" {
  name    = "cluster-subnet-rules"
  network = google_compute_network.benchmark_vpc.name

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  source_tags = ["kafka-cluster", "kafka-client"]
}

resource "google_compute_subnetwork" "client_subnet" {
  name          = "kafka-client-subnet"
  ip_cidr_range = "10.2.0.0/16"
  network       = google_compute_network.benchmark_vpc.id
}

resource "google_compute_firewall" "client_subnet_rules" {
  name    = "client-subnet-rules"
  network = google_compute_network.benchmark_vpc.name

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  source_tags = ["kafka-cluster"]
}

resource "google_compute_instance" "kafka1" {
  name         = "kafka-broker-1"
  machine_type = var.kafka_machine_type
  zone         = var.kafka1_zone
  tags         = ["kafka-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_20_image
      size  = var.kafka_disk_size
      type  = var.kafka_disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cluster_subnet.name
    network_ip = var.kafka1_ip
    access_config {
    }
  }
}

resource "google_compute_instance" "kafka2" {
  name         = "kafka-broker-2"
  machine_type = var.kafka_machine_type
  zone         = var.kafka2_zone
  tags         = ["kafka-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_20_image
      size  = var.kafka_disk_size
      type  = var.kafka_disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cluster_subnet.name
    network_ip = var.kafka2_ip
    access_config {
    }
  }
}

resource "google_compute_instance" "kafka3" {
  name         = "kafka-broker-3"
  machine_type = var.kafka_machine_type
  zone         = var.kafka3_zone
  tags         = ["kafka-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_20_image
      size  = var.kafka_disk_size
      type  = var.kafka_disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cluster_subnet.name
    network_ip = var.kafka3_ip
    access_config {
    }
  }
}

resource "google_compute_instance" "zookeeper1" {
  name         = "zookeeper-broker-1"
  machine_type = var.zookeeper_machine_type
  zone         = var.zookeeper1_zone
  tags         = ["zookeeper-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_20_image
      size  = var.zookeeper_disk_size
      type  = var.zookeeper_disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cluster_subnet.name
    network_ip = var.zookeeper1_ip
    access_config {
    }
  }
}

resource "google_compute_instance" "zookeeper2" {
  name         = "zookeeper-broker-2"
  machine_type = var.zookeeper_machine_type
  zone         = var.zookeeper2_zone
  tags         = ["zookeeper-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_20_image
      size  = var.zookeeper_disk_size
      type  = var.zookeeper_disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cluster_subnet.name
    network_ip = var.zookeeper2_ip
    access_config {
    }
  }
}

resource "google_compute_instance" "zookeeper3" {
  name         = "zookeeper-broker-3"
  machine_type = var.zookeeper_machine_type
  zone         = var.zookeeper3_zone
  tags         = ["zookeeper-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_20_image
      size  = var.zookeeper_disk_size
      type  = var.zookeeper_disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cluster_subnet.name
    network_ip = var.zookeeper3_ip
    access_config {
    }
  }
}
