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
    module.network,
    google_gke_hub_feature.asm,
    google_gke_hub_feature.acm
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

resource "google_gke_hub_membership" "development" {
  provider      = google-beta
  project       = var.project_id
  membership_id = "development-membership"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${module.gke_development.cluster_id}"
    }
  }
  authority {
    issuer = "https://container.googleapis.com/v1/${module.gke_development.cluster_id}"
  }
}

module "asm-development" {
    source = "terraform-google-modules/gcloud/google"

    platform = "linux"
    
    create_cmd_entrypoint = "gcloud"
    create_cmd_body = "container fleet mesh update --management automatic --memberships ${google_gke_hub_membership.development.membership_id} --project ${var.project_id}"
    destroy_cmd_entrypoint = "gcloud"
    destroy_cmd_body = "container fleet mesh update --management manual --memberships ${google_gke_hub_membership.development.membership_id} --project ${var.project_id}"
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
  policy_dir                = "iac/acm-multienv-cicd-anthos-autopilot/overlays/development"
  source_format             = "unstructured"

  depends_on = [
    module.asm-development
  ]

  providers = {
    kubernetes = kubernetes.development
  }
}
