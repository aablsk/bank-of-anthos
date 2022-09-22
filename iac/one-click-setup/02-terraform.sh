set -Eeuo pipefail

echo '🚀  Starting ./02-terraform.sh'
echo '🛠 Setting up project infrastructure with terraform.'
echo '🍵 🧉 🫖  This will take some time - why not get a hot beverage?  🍵 🧉 🫖'
terraform -chdir=iac/tf apply \
-var="project_id=$PROJECT_ID" \
-var="region=$REGION" \
-var="zone=$ZONE" \
-var="repo_owner=$GITHUB_REPO_OWNER" \
-var='teams=["frontend","accounts","ledger"]' \
-var='targets=["staging","production"]' \
-var="sync_repo=bank-of-anthos" # -auto-approve

echo '✅  Finished ./02-terraform.sh'