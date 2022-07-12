# service accounts
resource "google_service_account" "cloud_build" {
  account_id = "cloud-build-${var.team}"
}

resource "google_service_account" "cloud_deploy" {
  account_id = "cloud-deploy-${var.team}"
}

# project iam bindings
resource "google_project_iam_member" "cloud_build" {
  project = var.project_id

  for_each = toset([
    "roles/logging.logWriter",
    "roles/cloudbuild.builds.builder",
    "roles/clouddeploy.releaser"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "cloud_deploy" {
  project = var.project_id

  for_each = toset([
    "roles/logging.logWriter",
    # TODO: terraform does not allow for giving cluster specific rights? what is ebst practice here?
    "roles/container.developer",
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.cloud_deploy.email}"
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

resource "google_sourcerepo_repository_iam_member" "source_repository" {
  repository = var.source_repository.name
  project    = var.source_repository.project

  role   = "roles/source.reader"
  member = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_service_account_iam_member" "cloud_build_impersonate_cloud_deploy" {
  service_account_id = google_service_account.cloud_deploy.id
  role = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.cloud_build.email}"
}

