terraform {
  /* backend "gcs" {
      bucket = "tf-state-boa-tf"
      prefix = "bank-of-anthos"
  } */
}

# google-beta provider for fleet API, artifact registry
provider "google-beta" {
  project     = var.project_id
  region      = var.region
}

# default google provider for most resources
provider "google" {
  project     = var.project_id
  region      = var.region
}

# used to get project number
data "google_project" "project" {
}

# data needed for kubernetes provider
data "google_client_config" "default" {}