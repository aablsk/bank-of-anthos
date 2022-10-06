resource "google_gke_hub_feature" "asm" {
  name = "servicemesh"
  location = "global"
  project = var.project_id
  
  provider = google-beta

  depends_on = [
    module.enabled_google_apis
  ]
}

resource "google_gke_hub_feature" "acm" {
  name = "configmanagement"
  location = "global"
  project = var.project_id
  
  provider = google-beta

  depends_on = [
    module.enabled_google_apis
  ]
}