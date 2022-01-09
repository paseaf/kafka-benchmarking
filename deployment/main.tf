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

resource "google_compute_network" "benchmark-vpc" {
  name                    = "benchmark-vpc"
  description             = "network for kafka benchmarking"
  auto_create_subnetworks = false
}
resource "google_compute_firewall" "benchmark-vpc-rules" {
  name    = "benchmark-vpc-rules"
  network = google_compute_network.benchmark-vpc.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_subnetwork" "cluster-subnet" {
  name          = "kafka-cluster-subnet"
  ip_cidr_range = "10.1.0.0/16"
  network       = google_compute_network.benchmark-vpc.id
}
resource "google_compute_firewall" "cluster-subnet-rules" {
  name    = "cluster-subnet-rules"
  network = google_compute_network.benchmark-vpc.name

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  source_tags = ["kafka-cluster", "kafka-client"]
}

resource "google_compute_subnetwork" "client-subnet" {
  name          = "kafka-client-subnet"
  ip_cidr_range = "10.2.0.0/16"
  network       = google_compute_network.benchmark-vpc.id
}

resource "google_compute_firewall" "client-subnet-rules" {
  name    = "client-subnet-rules"
  network = google_compute_network.benchmark-vpc.name

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
  machine_type = var.kafka-machine-type
  zone         = var.kafka1-zone
  tags         = ["kafka-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu-20-image
      size  = var.kafka-disk-size
      type  = var.kafka-disk-type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cluster-subnet.name
    network_ip = var.kafka1-ip
    access_config {
    }
  }
}

resource "google_compute_instance" "kafka2" {
  name         = "kafka-broker-2"
  machine_type = var.kafka-machine-type
  zone         = var.kafka2-zone
  tags         = ["kafka-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu-20-image
      size  = var.kafka-disk-size
      type  = var.kafka-disk-type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cluster-subnet.name
    network_ip = var.kafka2-ip
    access_config {
    }
  }
}

resource "google_compute_instance" "kafka3" {
  name         = "kafka-broker-3"
  machine_type = var.kafka-machine-type
  zone         = var.kafka3-zone
  tags         = ["kafka-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu-20-image
      size  = var.kafka-disk-size
      type  = var.kafka-disk-type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cluster-subnet.name
    network_ip = var.kafka3-ip
    access_config {
    }
  }
}

resource "google_compute_instance" "zookeeper1" {
  name         = "zookeeper-broker-1"
  machine_type = var.zookeeper-machine-type
  zone         = var.zookeeper1-zone
  tags         = ["zookeeper-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu-20-image
      size  = var.zookeeper-disk-size
      type  = var.zookeeper-disk-type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cluster-subnet.name
    network_ip = var.zookeeper1-ip
    access_config {
    }
  }
}

resource "google_compute_instance" "zookeeper2" {
  name         = "zookeeper-broker-2"
  machine_type = var.zookeeper-machine-type
  zone         = var.zookeeper2-zone
  tags         = ["zookeeper-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu-20-image
      size  = var.zookeeper-disk-size
      type  = var.zookeeper-disk-type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cluster-subnet.name
    network_ip = var.zookeeper2-ip
    access_config {
    }
  }
}

resource "google_compute_instance" "zookeeper3" {
  name         = "zookeeper-broker-3"
  machine_type = var.zookeeper-machine-type
  zone         = var.zookeeper3-zone
  tags         = ["zookeeper-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu-20-image
      size  = var.zookeeper-disk-size
      type  = var.zookeeper-disk-type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.cluster-subnet.name
    network_ip = var.zookeeper3-ip
    access_config {
    }
  }
}
