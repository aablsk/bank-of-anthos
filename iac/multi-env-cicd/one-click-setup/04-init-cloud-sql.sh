set -Eeuo pipefail

echo '🚀  Starting ./04-init-cloud-sql.sh'

echo '🌱  Initializing staging db...'
echo '🔑  Getting cluster credentials...'
gcloud container clusters get-credentials staging --region=$REGION
echo '🙌  Deploying populate-db jobs for staging...'
skaffold config set default-repo $REGION-docker.pkg.dev/$PROJECT_ID/bank-of-anthos
skaffold run --profile=init-db-staging
echo '🕰  Wait for staging-db initialization to complete...'
kubectl wait --for=condition=complete job/populate-accounts-db job/populate-ledger-db -n bank-of-anthos-staging --timeout=300s

echo '🌱  Initializing production db...'
echo '🔑  Getting cluster credentials...'
gcloud container clusters get-credentials production --region=$REGION
echo '🙌  Deploying populate-db jobs for staging...'
skaffold config set default-repo $REGION-docker.pkg.dev/$PROJECT_ID/bank-of-anthos
skaffold run --profile=init-db-production
echo '🕰  Wait for production-db initialization to complete...'
kubectl wait --for=condition=complete job/populate-accounts-db job/populate-ledger-db -n bank-of-anthos-production --timeout=300s

echo '✅  Finished ./04-init-cloud-sql.sh'