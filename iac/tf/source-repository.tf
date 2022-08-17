resource "google_sourcerepo_repository" "source_mirror" {
  name = local.application_name
  project = var.project_id

  depends_on = [
    module.enabled_google_apis
  ]
}
