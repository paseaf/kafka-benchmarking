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

  allow {
    protocol = "tcp"
    ports    = ["22"]
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
  source_ranges = ["0.0.0.0/0"]
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
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "kafka1" {
  name         = "kafka1"
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
  name         = "kafka2"
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
  name         = "kafka3"
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
  name         = "zookeeper1"
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
  name         = "zookeeper2"
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
  name         = "zookeeper3"
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

resource "google_compute_instance" "client1" {
  name         = "client1"
  machine_type = var.client_machine_type
  zone         = var.client1_zone
  tags         = ["client-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_20_image
      size  = var.client_disk_size
      type  = var.client_disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.client_subnet.name
    network_ip = var.client1_ip
    access_config {
    }
  }
}

resource "google_compute_instance" "client2" {
  name         = "client2"
  machine_type = var.client_machine_type
  zone         = var.client2_zone
  tags         = ["client-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_20_image
      size  = var.client_disk_size
      type  = var.client_disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.client_subnet.name
    network_ip = var.client2_ip
    access_config {
    }
  }
}

resource "google_compute_instance" "client3" {
  name         = "client3"
  machine_type = var.client_machine_type
  zone         = var.client3_zone
  tags         = ["client-cluster"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_20_image
      size  = var.client_disk_size
      type  = var.client_disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.client_subnet.name
    network_ip = var.client3_ip
    access_config {
    }
  }
}
