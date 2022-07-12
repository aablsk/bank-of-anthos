data "google_project" "project" {
}

output "cluster" {
  value = google_container_cluster.cluster
}

output "network" {
  value = google_compute_network.network
}