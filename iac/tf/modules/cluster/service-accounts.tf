# service accounts
resource "google_service_account" "gke_workload" {
  account_id = "gke-workload-${var.cluster_name}"
}

# creating autopilot clusters in terraform does not support custom service accounts (https://github.com/hashicorp/terraform-provider-google/issues/9505) so we're using the default compute service account instead
# project iam bindings
resource "google_project_iam_member" "gke_node" {
  project = var.project_id

  role   = "roles/container.nodeServiceAgent"
  member = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "gke_workload" {
  project = var.project_id

  role   = "roles/cloudtrace.agent"
  member = "serviceAccount:${google_service_account.gke_workload.email}"
}

# additional roles for gke-node service account
resource "google_artifact_registry_repository_iam_member" "gke_node" {
  repository = var.container_registry.repository_id
  location   = var.region
  project    = var.project_id

  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"

  provider = google-beta
}

# setup workload identity
resource "google_service_account_iam_member" "gke_workload_identity" {
  service_account_id = google_service_account.gke_workload.id
  role = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.project_id}.svc.id.goog[default/default]"
}