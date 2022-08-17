/* # terraform does not support dynamic providers and modules are very limited in what they support regarding loops which is why we need to do all of these explicitly 🤷

# data needed for kubernetes provider
data "google_client_config" "default" {}

module "network" {
  source  = "terraform-google-modules/network/google"
  version = ">= 4.0.1, < 5.0.0"

  for_each = local.cluster_names

  project_id   = var.project_id
  network_name = local.network[each.key].network_name

  subnets = [
    {
      subnet_name   = local.network[each.key].subnet_name
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    },
    {
      subnet_name   = local.network[each.key].master_auth_subnet
      subnet_ip     = "10.60.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (local.network[each.key].subnet_name) = [
      {
        range_name    = local.network[each.key].pods_range_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = local.network[each.key].svc_range_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

# development cluster
provider "kubernetes" {
  alias                  = "development"
  host                   = "https://${module.gke_development.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_development.ca_certificate)
}

module "gke_development" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"

  project_id                      = var.project_id
  name                            = "development"
  regional                        = true
  region                          = var.region
  network                         = module.network["development"].network_name
  subnetwork                      = local.network["development"].subnet_name
  ip_range_pods                   = local.network["development"].pods_range_name
  ip_range_services               = local.network["development"].svc_range_name
  release_channel                 = "RAPID"
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling      = true

  providers = {
    kubernetes = kubernetes.development
  }
}

# staging cluster
provider "kubernetes" {
  alias                  = "staging"
  host                   = "https://${module.gke_staging.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_staging.ca_certificate)
}

module "gke_staging" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"

  project_id                      = var.project_id
  name                            = "staging"
  regional                        = true
  region                          = var.region
  network                         = module.network["staging"].network_name
  subnetwork                      = local.network["staging"].subnet_name
  ip_range_pods                   = local.network["staging"].pods_range_name
  ip_range_services               = local.network["staging"].svc_range_name
  release_channel                 = "RAPID"
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling      = true

  providers = {
    kubernetes = kubernetes.staging
  }
}

# production cluster
provider "kubernetes" {
  alias                  = "production"
  host                   = "https://${module.gke_production.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_production.ca_certificate)
}

module "gke_production" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"

  project_id                      = var.project_id
  name                            = "production"
  regional                        = true
  region                          = var.region
  network                         = module.network["production"].network_name
  subnetwork                      = local.network["production"].subnet_name
  ip_range_pods                   = local.network["production"].pods_range_name
  ip_range_services               = local.network["production"].svc_range_name
  release_channel                 = "RAPID"
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling      = true

  providers = {
    kubernetes = kubernetes.production
  }
}

module "workload_identity_development" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"

  name       = "gke-workload-development"
  project_id = var.project_id
  roles      = ["roles/cloudtrace.agent"]

  depends_on = [module.gke_development]

  providers = {
    kubernetes = kubernetes.development
  }
}

module "workload_identity_staging" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"

  name       = "gke-workload-staging"
  project_id = var.project_id
  roles      = ["roles/cloudtrace.agent"]

  depends_on = [module.gke_staging]

  providers = {
    kubernetes = kubernetes.staging
  }
}

module "workload_identity_production" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"

  name       = "gke-workload-production"
  project_id = var.project_id
  roles      = ["roles/cloudtrace.agent"]

  depends_on = [module.gke_production]

  providers = {
    kubernetes = kubernetes.production
  }
} */
