module "ci-cd-pipeline" {
  source = "./modules/ci-cd-pipeline"

  for_each = var.teams
  depends_on = [
    google_project_service.cloudbuild,
    google_project_service.clouddeploy
  ]

  project_id = var.project_id
  region = var.region
  container_registry = google_artifact_registry_repository.container_registry
  source_repository = google_sourcerepo_repository.source_mirror
  team = each.key
  pipeline_definition_filename = each.value
  clusters = module.clusters
  targets = var.targets
}
