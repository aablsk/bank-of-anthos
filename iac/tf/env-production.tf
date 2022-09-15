provider "kubernetes" {
  alias                  = "production"
  host                   = "https://${module.gke_production.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_production.ca_certificate)
}

module "gke_production" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"

  project_id        = var.project_id
  name              = "production"
  regional          = true
  region            = var.region
  network           = local.network_name
  subnetwork        = local.network.production.subnetwork
  ip_range_pods     = local.network.production.ip_range_pods
  ip_range_services = local.network.production.ip_range_services
  #master_authorized_networks      = local.network.production.master_auth_subnet_name
  release_channel                 = "RAPID"
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling      = true
  create_service_account          = false # currently not supported by terraform for autopilot clusters
  cluster_resource_labels         = { "mesh_id" : "proj-${data.google_project.project.number}" }
  datapath_provider               = "ADVANCED_DATAPATH"

  providers = {
    kubernetes = kubernetes.production
  }

  depends_on = [
    module.enabled_google_apis,
    module.network,
    google_gke_hub_feature.asm,
    google_gke_hub_feature.acm
  ]
}

resource "google_service_account" "gke_workload_production" {
  account_id = "gke-workload-production"
}

resource "google_service_account_iam_member" "gke_workload_production_identity" {
  service_account_id = google_service_account.gke_workload_production.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[bank-of-anthos-production/bank-of-anthos]"
  depends_on = [
    module.gke_production
  ]
}

resource "google_gke_hub_membership" "production" {
  provider      = google-beta
  project       = var.project_id
  membership_id = "production-membership"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${module.gke_production.cluster_id}"
    }
  }
  authority {
    issuer = "https://container.googleapis.com/v1/${module.gke_production.cluster_id}"
  }
}

module "asm-production" {
    source = "terraform-google-modules/gcloud/google"

    platform = "linux"
    
    create_cmd_entrypoint = "gcloud"
    create_cmd_body = "container fleet mesh update --management automatic --memberships ${google_gke_hub_membership.production.membership_id} --project ${var.project_id}"
    destroy_cmd_entrypoint = "gcloud"
    destroy_cmd_body = "container fleet mesh update --management manual --memberships ${google_gke_hub_membership.production.membership_id} --project ${var.project_id}"
}

# module "asm-production" { # needs this PR to work: https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/pull/1354
#   source           = "terraform-google-modules/kubernetes-engine/google//modules/asm"
#   project_id       = var.project_id
#   cluster_name     = module.gke_production.name
#   cluster_location = module.gke_production.location
#   enable_cni       = true

#   module_depends_on = [
#     google_gke_hub_membership.production
#   ]

#   providers = {
#     kubernetes = kubernetes.production
#   }
# }

module "acm-production" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/acm"

  project_id                = var.project_id
  cluster_name              = module.gke_production.name
  cluster_membership_id     = "production-membership"
  location                  = module.gke_production.location
  sync_repo                 = local.sync_repo_url
  sync_branch               = var.sync_branch
  enable_fleet_feature      = false
  enable_fleet_registration = false
  policy_dir                = "iac/acm/overlays/production"
  source_format             = "unstructured"

  depends_on = [
    module.asm-production
  ]

  providers = {
    kubernetes = kubernetes.production
  }
}

