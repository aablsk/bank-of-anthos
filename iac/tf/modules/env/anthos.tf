/* module "gke" {
    source = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"

    project_id = var.project_id
    name = var.env_name
    regional = true
    region = var.region
    network = module.gcp_network.network_name
    subnetwork = local.subnet_names[index(module.gcp_network.subnets_names, local.subnet_name)]
    ip_range_pods = local.pods_range_name
    ip_range_services = local.svc_range_name
    release_channel = "RAPID"
    enable_vertical_pod_autoscaling = true
    horizontal_pod_autoscaling = true
    create_service_account = false #currently not supported by terraform for autopilot clusters
} */
/*resource "google_gke_hub_feature" "configmanagement_acm_feature" {
  provider = google-beta
  name     = "configmanagement"
  location = "global"
}

/*resource "google_gke_hub_feature_membership" "membership" {
  provider   = google-beta
  location   = "global"
  feature    = "configmanagement"
  membership = "${var.gke.name}-membership"
  configmanagement {
    config_sync {
      source_format = "unstructured"
      git {
        sync_repo   = var.sync_repo
        sync_branch = var.sync_branch
        sync_rev    = var.sync_rev
        policy_dir  = var.policy_dir
        secret_type = "none"
      }
    }
  }
  depends_on = [
    google_gke_hub_feature.configmanagement_acm_feature
  ]
} */

/* module "istio-annotation" {
  source = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"

  project_id              = data.google_project.project.project_id
  cluster_name            = var.gke.name
  cluster_location        = var.gke.location
  module_depends_on       = [var.gke]
  kubectl_create_command  = "kubectl annotate --overwrite namespace default mesh.cloud.google.com/proxy='{\"managed\":\"true\"}'"
  kubectl_destroy_command = "kubectl annotate --overwrite namespace default mesh.cloud.google.com/proxy='{\"managed\":\"false\"}'"
} # can this be done with ACM?!


module "istio-injection-label" {
  source = "terraform-google-modules/gcloud/google//modules/kubectl-wrapper"

  project_id              = data.google_project.project.project_id
  cluster_name            = var.gke.name
  cluster_location        = var.gke.location
  module_depends_on       = [var.gke]
  kubectl_create_command  = "kubectl label namespace default istio-injection=enabled istio.io/rev- --overwrite"
  kubectl_destroy_command = "kubectl label namespace default istio-injection-"
} # can this be done with ACM? */


/* module "hub" {
  source         = "terraform-google-modules/kubernetes-engine/google//modules/fleet-membership"
  project_id     = var.project_id
  cluster_name   = var.gke.name
  location       = var.gke.location
  hub_project_id = var.project_id
} */

