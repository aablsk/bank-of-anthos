resource "google_container_cluster" "cluster" {
  name             = var.cluster_name
  enable_autopilot = true
  network          = google_compute_network.network.self_link
  location         = var.region
  ip_allocation_policy {
  }
}
