resource "google_artifact_registry_repository" "container_registry" {
  repository_id = local.application_name
  location      = var.region
  format        = "docker"
  description   = "Bank of Anthos docker repository"
  project       = var.project_id

  provider = google-beta

  depends_on = [
    google_project_service.artifactregistry
  ]
}