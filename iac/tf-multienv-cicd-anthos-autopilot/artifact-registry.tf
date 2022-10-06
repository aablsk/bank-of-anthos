# create artifact registry for container images
resource "google_artifact_registry_repository" "container_registry" {
  repository_id = local.application_name
  location      = var.region
  format        = "docker"
  description   = "Bank of Anthos docker repository"
  project       = var.project_id

  provider = google-beta

  depends_on = [
    module.enabled_google_apis
  ]
}

# we cannot use a custom service account with autopilot clusters in terraform https://github.com/hashicorp/terraform-provider-google/issues/9505 🤷
# so we're using the default compute service account here...
module "artifact-registry-repository-iam-bindings" {
  source       = "terraform-google-modules/iam/google//modules/artifact_registry_iam"
  project      = var.project_id
  repositories = [local.application_name]
  location     = var.region
  mode         = "additive"

  bindings = {
    "roles/artifactregistry.reader" = ["serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"]
  }

  depends_on = [
    module.enabled_google_apis,
    google_artifact_registry_repository.container_registry
  ]
}
