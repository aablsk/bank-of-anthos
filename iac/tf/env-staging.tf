provider "kubernetes" {
  alias                  = "staging"
  host                   = "https://${module.gke_staging.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_staging.ca_certificate)
}

module "gke_staging" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"

  project_id        = var.project_id
  name              = "staging"
  regional          = true
  region            = var.region
  network           = local.network_name
  subnetwork        = local.network.staging.subnetwork
  ip_range_pods     = local.network.staging.ip_range_pods
  ip_range_services = local.network.staging.ip_range_services
  #master_authorized_networks      = local.network.staging.master_auth_subnet_name
  release_channel                 = "RAPID"
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling      = true
  create_service_account          = false # currently not supported by terraform for autopilot clusters
  cluster_resource_labels         = { "mesh_id" : "proj-${data.google_project.project.number}" }
  datapath_provider               = "ADVANCED_DATAPATH"

  providers = {
    kubernetes = kubernetes.staging
  }

  depends_on = [
    module.enabled_google_apis,
    module.network,
    google_gke_hub_feature.asm,
    google_gke_hub_feature.acm
  ]
}

resource "google_service_account" "gke_workload_staging" {
  account_id = "gke-workload-staging"
}

resource "google_service_account_iam_member" "gke_workload_staging_identity" {
  service_account_id = google_service_account.gke_workload_staging.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[bank-of-anthos-staging/bank-of-anthos]"
  depends_on = [
    module.gke_staging
  ]
}

module "cloudsql_staging" {
  source = "GoogleCloudPlatform/sql-db/google//modules/postgresql"

  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  name              = "${local.cloudsql_name}-staging"
  database_version  = "POSTGRES_14"
  enable_default_db = false
  # ip_configuration - should we use this or is default ok?
  tier = "db-custom-1-3840"
  deletion_protection = false

  additional_databases = [
    {
      name      = "accounts-db"
      charset   = ""
      collation = ""
    },
    {
      name      = "ledger-db"
      charset   = ""
      collation = ""
    }
  ]
  user_name     = "admin"
  user_password = "admin" # this is a security risk - do not do this for real world use-cases!
}

resource "google_gke_hub_membership" "staging" {
  provider      = google-beta
  project       = var.project_id
  membership_id = "staging-membership"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${module.gke_staging.cluster_id}"
    }
  }
  authority {
    issuer = "https://container.googleapis.com/v1/${module.gke_staging.cluster_id}"
  }
}

module "asm-staging" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  project_id       = var.project_id
  cluster_name     = module.gke_staging.name
  cluster_location = module.gke_staging.location
  enable_cni       = true

  module_depends_on = [
    google_gke_hub_membership.staging
  ]

  providers = {
    kubernetes = kubernetes.staging
  }
}


module "acm-staging" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/acm"

  project_id                = var.project_id
  cluster_name              = module.gke_staging.name
  cluster_membership_id     = "staging-membership"
  location                  = module.gke_staging.location
  sync_repo                 = local.sync_repo_url
  sync_branch               = var.sync_branch
  enable_fleet_feature      = false
  enable_fleet_registration = false
  policy_dir                = "iac/acm/overlays/staging"
  source_format             = "unstructured"

  depends_on = [
    module.asm-staging
  ]

  providers = {
    kubernetes = kubernetes.staging
  }
}
