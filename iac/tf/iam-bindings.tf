module "project-iam-bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id]
  mode     = "authoritative"

  bindings = {
    "roles/cloudtrace.agent" = [
      "serviceAccount:${google_service_account.gke_workload_development.email}",
    ],
    "roles/monitoring.metricWriter" = [
      "serviceAccount:${google_service_account.gke_workload_development.email}",
      "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
    ],
    "roles/logging.logWriter" = [
      "serviceAccount:${google_service_account.gke_workload_development.email}",
      "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
    ],

  }
}





/* resource "google_project_iam_member" "gke_workload_development_cloudtraceAgent" {
    project = var.project_id
    role = "roles/cloudtrace.agent"
    member = "serviceAccount:${google_service_account.gke_workload.email}"
}

resource "google_project_iam_member" "gke_workload_development_metricWriter" {
    project = var.project_id
    role = "roles/monitoring.metricWriter"
    member = "serviceAccount:${google_service_account.gke_workload.email}"
}

resource "google_project_iam_member" "gke_workload_development_logWriter" {
    project = var.project_id
    role = "roles/logging.logWriter"
    member = "serviceAccount:${google_service_account.gke_workload.email}"
} */

/* resource "google_project_iam_member" "gke_node_logWriter" {
    project = var.project_id
    role = "roles/logging.logWriter"
    member = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "gke_node_metricWriter" {
    project = var.project_id
    role = "roles/monitoring.metricWriter"
    member = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
} */
