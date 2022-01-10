output "kafka1_int_ip" {
  value = google_compute_instance.kafka1.network_interface.0.network_ip
}

output "kafka1_ext_ip" {
  value = google_compute_instance.kafka1.network_interface.0.access_config.0.nat_ip
}
output "kafka2_int_ip" {
  value = google_compute_instance.kafka2.network_interface.0.network_ip
}

output "kafka2_ext_ip" {
  value = google_compute_instance.kafka2.network_interface.0.access_config.0.nat_ip
}
output "kafka3_int_ip" {
  value = google_compute_instance.kafka3.network_interface.0.network_ip
}

output "kafka3_ext_ip" {
  value = google_compute_instance.kafka3.network_interface.0.access_config.0.nat_ip
}
output "zookeeper1_int_ip" {
  value = google_compute_instance.zookeeper1.network_interface.0.network_ip
}
output "zookeeper1_ext_ip" {
  value = google_compute_instance.zookeeper1.network_interface.0.access_config.0.nat_ip
}

output "zookeeper2_int_ip" {
  value = google_compute_instance.zookeeper2.network_interface.0.network_ip
}
output "zookeeper2_ext_ip" {
  value = google_compute_instance.zookeeper2.network_interface.0.access_config.0.nat_ip
}
output "zookeeper3_int_ip" {
  value = google_compute_instance.zookeeper3.network_interface.0.network_ip
}
output "zookeeper3_ext_ip" {
  value = google_compute_instance.zookeeper3.network_interface.0.access_config.0.nat_ip
}
