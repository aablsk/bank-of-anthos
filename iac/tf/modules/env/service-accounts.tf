# service accounts
resource "google_service_account" "gke_workload" {
  account_id = "gke-workload-${var.env_name}"
}

resource "google_project_iam_member" "gke_workload_cloudtraceAgent" {
    project = var.project_id
    role = "roles/cloudtrace.agent"
    member = "serviceAccount:${google_service_account.gke_workload.email}"
}

resource "google_project_iam_member" "gke_workload_metricWriter" {
    project = var.project_id
    role = "roles/monitoring.metricWriter"
    member = "serviceAccount:${google_service_account.gke_workload.email}"
}

resource "google_project_iam_member" "gke_workload_logWriter" {
    project = var.project_id
    role = "roles/logging.logWriter"
    member = "serviceAccount:${google_service_account.gke_workload.email}"
}

# setup workload identity
resource "google_service_account_iam_member" "gke_workload_identity" {
  service_account_id = google_service_account.gke_workload.id
  role = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.project_id}.svc.id.goog[bank-of-anthos/bank-of-anthos]"
}

