locals {
  # The name of the application. This will be used for naming of registry, repository.
  application_name = "bank-of-anthos"
  cluster_names    = toset(["development", "staging", "production"])
  network_name     = "shared-gke"
  network = { for name in local.cluster_names : name =>
    {
      subnetwork              = "${name}-gke-subnet"
      master_auth_subnet_name = "${name}-gke-master-auth-subnet"
      ip_range_pods           = "${name}-ip-range-pods"
      ip_range_services       = "${name}-ip-range-svc"
  } }
  clusters = {
    "development" = module.gke_development
    "staging"     = module.gke_staging
    "production"  = module.gke_production
  }
  sync_repo_url = "https://www.github.com/${var.repo_owner}/${var.sync_repo}"
}
