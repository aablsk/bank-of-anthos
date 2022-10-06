set -uo pipefail

echo '🚀  Starting ./01-patch-acm-config.sh'
echo '🧐  Replacing references to ProjectId in Anthos Config Management configuration...'
find iac/acm-multienv-cicd-anthos-autopilot/* -type f -exec sed -i 's/boa-tf-max-6/'"$PROJECT_ID"'/g' {} +

echo '🧐  Replacing references to Region in Anthos Config Management configuration...'
find iac/acm-multienv-cicd-anthos-autopilot/* -type f -exec sed -i 's/europe-west1/'"$REGION"'/g' {} +

echo '📤  Committing & pushing changes to Git...'
git add iac/acm-multienv-cicd-anthos-autopilot
git commit -m "substitute projectId and region references in ACM config"
git push
echo '✅  Finished ./01-patch-acm-config.sh'