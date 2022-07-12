module "clusters" {
  source = "./modules/cluster"

  for_each = var.cluster_names
  depends_on = [
    google_artifact_registry_repository.container_registry,
    google_project_service.compute,
    google_project_service.container
  ]

  cluster_name       = each.key
  container_registry = google_artifact_registry_repository.container_registry
  project_id         = var.project_id
  region             = var.region
}