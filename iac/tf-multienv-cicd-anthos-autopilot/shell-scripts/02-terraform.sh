set -Eeuo pipefail

echo '🚀  Starting ./02-terraform.sh'
echo '🛠 Setting up project infrastructure with terraform.'
echo '🍵 🧉 🫖  This will take some time - why not get a hot beverage?  🍵 🧉 🫖'
terraform -chdir=iac/tf-multienv-cicd-anthos-autopilot init

terraform -chdir=iac/tf-multienv-cicd-anthos-autopilot apply \
-var="project_id=$PROJECT_ID" \
-var="region=$REGION" \
-var="zone=$ZONE" \
-var="repo_owner=$GITHUB_REPO_OWNER" \
-auto-approve

echo '✅  Finished ./02-terraform.sh'