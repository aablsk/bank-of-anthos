# data needed for kubernetes provider
data "google_client_config" "default" {}

provider "kubernetes" {
  alias                  = "development"
  host                   = "https://${module.gke_development.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_development.ca_certificate)
}

module "env_development" {
  source = "./modules/env"

  project_id = var.project_id
  region     = var.region
  env_name   = "development"
  gke        = module.gke_development

  providers = {
    kubernetes = kubernetes.development
  }

  depends_on = [
    module.enabled_google_apis
  ]
}

module "gke_development" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"

  project_id                      = var.project_id
  name                            = "development"
  regional                        = true
  region                          = var.region
  network                         = module.env_development.network_name
  subnetwork                      = module.env_development.subnetwork
  ip_range_pods                   = module.env_development.ip_range_pods
  ip_range_services               = module.env_development.ip_range_services
  release_channel                 = "RAPID"
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling      = true
  create_service_account          = false #currently not supported by terraform for autopilot clusters
  cluster_resource_labels         = { "mesh_id" : "${var.project_id}-development" }
  datapath_provider               = "ADVANCED_DATAPATH"

  providers = {
    kubernetes = kubernetes.development
  }

  depends_on = [
    module.enabled_google_apis
  ]
}

resource "google_gke_hub_feature" "configmanagement_acm_feature" {
  provider = google-beta
  name     = "configmanagement"
  location = "global"

  depends_on = [
    module.enabled_google_apis
  ]
}

module "acm" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/acm"

  project_id                = var.project_id
  cluster_name              = module.gke_development.name
  location                  = module.gke.location
  sync_repo                 = var.sync_repo
  sync_branch               = var.sync_branch
  enable_fleet_feature      = false
  enable_fleet_registration = true
  policy_dir                = "iac/acm/overlays/development"
  source_format             = "unstructured"

  providers = {
    kubernetes = kubernetes.development
  }
}

/* module "asm" {
  source                    = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  version                   = "~> 22.1.0"
  project_id                = var.project_id
  cluster_name              = module.gke_development.name
  cluster_location          = module.gke_development.location
  enable_cni                = true
  enable_fleet_registration = true
  enable_mesh_feature       = true  

  depends_on = [module.enabled_google_apis]

  providers = {
    kubernetes = kubernetes.development
  }
} */
