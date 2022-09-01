provider "kubernetes" {
  alias                  = "development"
  host                   = "https://${module.gke_development.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_development.ca_certificate)
}

module "gke_development" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"

  project_id        = var.project_id
  name              = "development"
  regional          = true
  region            = var.region
  network           = local.network_name
  subnetwork        = local.network.development.subnetwork
  ip_range_pods     = local.network.development.ip_range_pods
  ip_range_services = local.network.development.ip_range_services
  #master_authorized_networks      = local.network.development.master_auth_subnet_name
  release_channel                 = "RAPID"
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling      = true
  create_service_account          = false # currently not supported by terraform for autopilot clusters
  cluster_resource_labels         = { "mesh_id" : "proj-${data.google_project.project.number}" }
  datapath_provider               = "ADVANCED_DATAPATH"

  providers = {
    kubernetes = kubernetes.development
  }

  depends_on = [
    module.enabled_google_apis,
    google_gke_hub_feature.asm,
    google_gke_hub_feature.acm,
    module.network
  ]
}

resource "google_service_account" "gke_workload_development" {
  account_id = "gke-workload-development"
}

resource "google_service_account_iam_member" "gke_workload_development_identity" {
  service_account_id = google_service_account.gke_workload_development.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[bank-of-anthos-development/bank-of-anthos]"
  depends_on = [
    module.gke_development
  ]
}

module "asm-development" { # needs this PR to work: https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/pull/1354
  source                    = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  project_id                = var.project_id
  cluster_name              = module.gke_development.name
  cluster_location          = module.gke_development.location
  enable_cni                = true
  enable_fleet_registration = true

  module_depends_on = [
    module.gke_development,
  ]

  providers = {
    kubernetes = kubernetes.development
  }
}

module "acm-development" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/acm"

  project_id                = var.project_id
  cluster_name              = module.gke_development.name
  cluster_membership_id     = "development-membership"
  location                  = module.gke_development.location
  sync_repo                 = local.sync_repo_url
  sync_branch               = var.sync_branch
  enable_fleet_feature      = false
  enable_fleet_registration = false
  policy_dir                = "iac/acm/overlays/development"
  source_format             = "unstructured"

  depends_on = [
    module.asm-development
  ]

  providers = {
    kubernetes = kubernetes.development
  }
}
