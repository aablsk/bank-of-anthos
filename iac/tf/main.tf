terraform {
  backend "gcs" {
      bucket = "tf-state-boa-tf"
      prefix = "bank-of-anthos"
  }
}
provider "google-beta" {
  project     = var.project_id
  region      = var.region
}

provider "google" {
  project     = var.project_id
  region      = var.region
}

