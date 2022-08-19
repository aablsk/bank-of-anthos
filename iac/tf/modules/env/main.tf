terraform {
  required_providers {
    kubernetes = {
        source = "hashicorp/kubernetes"
    }
    google-beta = {
        source = "hashicorp/google-beta"
    }
    google = {
        source = "hashicorp/google"
    }
  }
}   

data "google_project" "project" {
}

locals {
  network_name           = "${var.env_name}-network"
  subnet_name            = "${var.env_name}-gke-subnet"
  master_auth_subnetwork = "${var.env_name}-gke-master-subnet"
  pods_range_name        = "${var.env_name}-ip-range-pods"
  svc_range_name         = "${var.env_name}-ip-range-svc"
  subnet_names           = [for subnet_self_link in module.network.subnets_self_links : split("/", subnet_self_link)[length(split("/", subnet_self_link)) - 1]]
}
