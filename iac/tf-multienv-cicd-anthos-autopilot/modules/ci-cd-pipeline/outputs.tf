output "cloud_build_sa" {
  value = "serviceAccount:${google_service_account.cloud_build.email}"
}

output "cloud_deploy_sa" {
  value = "serviceAccount:${google_service_account.cloud_deploy.email}"
}