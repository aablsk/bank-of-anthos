# cloud build service account
resource "google_service_account" "cloud_build" {
  account_id = "cloud-build-${var.team}"
}

# cloud deploy service account
resource "google_service_account" "cloud_deploy" {
  account_id = "cloud-deploy-${var.team}"
}

# additional roles for cloud-build service account
resource "google_artifact_registry_repository_iam_member" "cloud_build" {
  repository = var.container_registry.repository_id
  location   = var.container_registry.location
  project    = var.container_registry.project

  role   = "roles/artifactregistry.writer"
  member = "serviceAccount:${google_service_account.cloud_build.email}"

  provider = google-beta
}

resource "google_service_account_iam_member" "cloud_build_impersonate_cloud_deploy" {
  service_account_id = google_service_account.cloud_deploy.id
  role = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.cloud_build.email}"
}

