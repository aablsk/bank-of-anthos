terraform {
  /* backend "gcs" {
      bucket = "tf-state-boa-tf"
      prefix = "bank-of-anthos"
  } */
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
}

provider "google" {
  project     = var.project_id
  region      = var.region
}

data "google_project" "project" {
}

# data needed for kubernetes provider
data "google_client_config" "default" {}