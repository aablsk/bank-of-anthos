resource "google_project_service" "artifactregistry" {
    service = "artifactregistry.googleapis.com" 
}

resource "google_project_service" "sourcerepo" {
  service = "sourcerepo.googleapis.com"
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "clouddeploy" {
  service = "clouddeploy.googleapis.com"
}