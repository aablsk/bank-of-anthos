project_id = "boa-tf"
region = "europe-west1"
cluster_names = ["development", "staging", "production"]
teams = {
    "frontend" = "cloudbuild.yaml"
    "accounts" = "cloudbuild.yaml"
    "ledger"   = "cloudbuild-mvnw.yaml"
}
targets = ["staging", "production"]