module "ci-cd-pipeline" {
  source = "./modules/ci-cd-pipeline"

  for_each = toset(var.teams)

  project_id = var.project_id
  region = var.region
  container_registry = google_artifact_registry_repository.container_registry
  repo_owner = var.repo_owner
  repo_name = var.sync_repo
  team = each.value
  clusters = local.clusters
  targets = var.targets

  depends_on = [
    module.enabled_google_apis
  ]
}