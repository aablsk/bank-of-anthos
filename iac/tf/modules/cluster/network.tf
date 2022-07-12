resource "google_compute_network" "network" {
    name = var.cluster_name
    auto_create_subnetworks = true
}