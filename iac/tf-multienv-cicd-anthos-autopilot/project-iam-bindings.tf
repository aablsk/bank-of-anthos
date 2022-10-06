# authoritative project-iam-bindings to increase reproducibility
module "project-iam-bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id]
  mode     = "authoritative"

  bindings = {
    "roles/cloudtrace.agent" = [
      "serviceAccount:${google_service_account.gke_workload_development.email}",
      "serviceAccount:${google_service_account.gke_workload_staging.email}",
      "serviceAccount:${google_service_account.gke_workload_production.email}",
      "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
    ],
    "roles/monitoring.metricWriter" = [
      "serviceAccount:${google_service_account.gke_workload_development.email}",
      "serviceAccount:${google_service_account.gke_workload_staging.email}",
      "serviceAccount:${google_service_account.gke_workload_production.email}",
      "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
    ],
    "roles/logging.logWriter" = setunion(
      [
        "serviceAccount:${google_service_account.gke_workload_development.email}",
        "serviceAccount:${google_service_account.gke_workload_staging.email}",
        "serviceAccount:${google_service_account.gke_workload_production.email}",
        "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
      ],
      local.cloud_build_sas,
      local.cloud_deploy_sas
    ),
    "roles/cloudbuild.builds.builder" = setunion(
      [
        "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
        "user:admin@bielski.altostrat.com"
      ],
      local.cloud_build_sas
    ),
    "roles/clouddeploy.releaser" = local.cloud_build_sas,
    "roles/container.developer"  = local.cloud_deploy_sas,
    "roles/cloudsql.client" = [
        "serviceAccount:${google_service_account.gke_workload_staging.email}", # this implies that staging service account also has access to production CloudSQL. Could be solved by putting the CloudSQL instances in separate projects,
        "serviceAccount:${google_service_account.gke_workload_production.email}", # this implies that production service account also has access to staging CloudSQL. Could be solved by putting the CloudSQL instances in separate projects.
    ],
    "roles/cloudsql.instanceUser" = [
        "serviceAccount:${google_service_account.gke_workload_staging.email}", # this implies that staging service account also has access to production CloudSQL. Could be solved by putting the CloudSQL instances in separate projects,
        "serviceAccount:${google_service_account.gke_workload_production.email}", # this implies that production service account also has access to staging CloudSQL. Could be solved by putting the CloudSQL instances in separate projects.
    ]
  }
}
